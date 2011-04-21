package mesh.services
{
	import collections.HashSet;
	
	import flash.errors.IllegalOperationError;
	
	import mesh.core.array.flatten;
	import mesh.core.reflection.Type;
	import mesh.model.Entity;
	import mesh.operations.Operation;

	/**
	 * The <code>Service</code> class is a layer between the application and the backend. Its
	 * purpose is to keep track of which entities were retrieved by the backend, which entities 
	 * need to be persisted back to the backend, and how.
	 * 
	 * @author Dan Schultz
	 */
	public dynamic class Service
	{
		private var _registered:HashSet = new HashSet();
		private var _factory:Function;
		
		/**
		 * Constructor.
		 */
		public function Service(factory:Function)
		{
			_factory = factory;
		}
		
		/**
		 * Generates an operation to retrieve all entities of a certain type from the backend.
		 * 
		 * @param options Any options to query with.
		 * @return An unexecuted operation.
		 */
		public function all():ListQueryRequest
		{
			return new ListQueryRequest(this, deserialize, function():Operation
			{
				return createAllOperation();
			});
		}
		
		protected function createAllOperation():Operation
		{
			throw new IllegalOperationError(reflect.name + " does not support retrieval of entities using all()");
		}
		
		public function belongingTo(entity:Entity):ListQueryRequest
		{
			return new ListQueryRequest(this, deserialize, function():Operation
			{
				return createBelongingToOperation(entity);
			});
		}
		
		protected function createBelongingToOperation(entity:Entity):Operation
		{
			throw new IllegalOperationError(reflect.name + " does not support retrieval of entities belonging to " + entity);
		}
		
		/**
		 * Generates an operation that is specific for this service adaptor.
		 * 
		 * @param args The args to pass to the constructor of the operation.
		 * @return A new unexecuted operation.
		 */
		protected function createOperation(...args):Operation
		{
			throw new IllegalOperationError(reflect.name + ".createOperation() is not implemented.");
		}
		
		protected function deserialize(items:Array):Array
		{
			return items.map(function(item:Object, ...args):Entity
			{
				var entity:Entity = _factory(item);
				entity.translateFrom(item);
				return entity;
			});
		}
		
		protected function serialize(entities:Array):Array
		{
			return entities.map(function(entity:Entity, ...args):Object
			{
				return entity.translateTo();
			});
		}
		
		/**
		 * Marks the given entities to be destroyed the next time this service is saved.
		 * 
		 * @param entities The entities to destroy.
		 */
		public function destroy(entities:Object):DestroyRequest
		{
			entities = pendingDestroy(flatten(entities));
			return new DestroyRequest(this, entities as Array, function():Operation
			{
				return createDestroyOperation(entities as Array);
			});
		}
		
		protected function createDestroyOperation(entities:Array):Operation
		{
			throw new IllegalOperationError(reflect.name + " does not support retrieval destruction entities.");
		}
		
		/**
		 * Generates an operation that retrieves a list of entities with the given IDs.
		 * 
		 * @param ids The IDs of the objects to retrieve.
		 * @return An unexecuted operation.
		 */
		public function find(...ids):QueryRequest
		{
			ids = flatten(ids);
			return ids.length == 1 ? findOne(ids[0]) : findMany(ids);
		}
		
		public function findOne(id:*):ItemQueryRequest
		{
			return new ItemQueryRequest(this, deserialize, function():Operation
			{
				return createFindOneOperation(id);
			});
		}
		
		protected function createFindOneOperation(id:*):Operation
		{
			throw new IllegalOperationError(reflect.name + " does not support retrieval of entities using findOne().");
		}
		
		public function findMany(...ids):ListQueryRequest
		{
			return new ListQueryRequest(this, deserialize, function():Operation
			{
				return createFindManyOperation.apply(null, ids);
			});
		}
		
		protected function createFindManyOperation(...ids):Operation
		{
			throw new IllegalOperationError(reflect.name + " does not support retrieval of entities using findMany().");
		}
		
		public function insert(entities:Object):InsertRequest
		{
			entities = pendingCreate(flatten(entities));
			return new InsertRequest(this, entities as Array, function():Operation
			{
				return createInsertOperation(entities as Array);
			});
		}
		
		protected function createInsertOperation(entities:Array):Operation
		{
			throw new IllegalOperationError(reflect.name + " does not support insertion of entities.");
		}
		
		private function pendingCreate(entities:Array):Array
		{
			return entities.filter(function(entity:Entity, ...args):Boolean
			{
				return entity.isNew;
			});
		}
		
		private function pendingDestroy(entities:Array):Array
		{
			return entities.filter(function(entity:Entity, ...args):Boolean
			{
				return entity.isMarkedForRemoval;
			});
		}
		
		private function pendingUpdate(entities:Array):Array
		{
			return entities.filter(function(entity:Entity, ...args):Boolean
			{
				return entity.isPersisted && entity.hasPropertyChanges;
			});
		}
		
		public function register(entities:Object):void
		{
			_registered.addAll(flatten(entities));
		}
		
		public function unregister(entities:Object):void
		{
			_registered.removeAll(flatten(entities));
		}
		
		public function save(entities:Object):Request
		{
			return insert(entities).then(update(entities));
		}
		
		public function saveAll():Request
		{
			return save(_registered.toArray());
		}
		
		public function update(entities:Object):UpdateRequest
		{
			entities = pendingUpdate(flatten(entities));
			return new UpdateRequest(this, entities as Array, function():Operation
			{
				return createUpdateOperation(entities as Array);
			});
		}
		
		protected function createUpdateOperation(entities:Array):Operation
		{
			throw new IllegalOperationError(reflect.name + " does not support updating of entities.");
		}
		
		/**
		 * Generates an operation that retrieves a list of entities using an options hash.
		 * 
		 * @param options The options to limit the retrieval.
		 * @return An unexecuted operation.
		 */
		public function where():WhereQueryRequest
		{
			throw new IllegalOperationError(reflect.name + " does not support retrieval of entities using where().");
		}
		
		private var _reflect:Type;
		/**
		 * A reflection object for this service.
		 */
		protected function get reflect():Type
		{
			if (_reflect == null) {
				_reflect = Type.reflect(this);
			}
			return _reflect;
		}
	}
}