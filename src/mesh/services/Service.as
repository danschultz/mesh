package mesh.services
{
	import collections.HashSet;
	
	import flash.errors.IllegalOperationError;
	import flash.utils.flash_proxy;
	
	import mesh.core.array.flatten;
	import mesh.core.reflection.Type;
	import mesh.model.Entity;
	import mesh.operations.EmptyOperation;
	import mesh.operations.Operation;
	
	use namespace flash_proxy;
	
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
		
		/**
		 * Constructor.
		 */
		public function Service(entity:Class, options:Object = null)
		{
			_entity = entity;
			_options = options != null ? options : {};
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
		
		public function belongingTo(entity:Entity, options:Object = null):ListQueryRequest
		{
			return new ListQueryRequest(this, deserialize, function():Operation
			{
				return createBelongingToOperation(entity, options);
			});
		}
		
		protected function createBelongingToOperation(entity:Entity, options:Object = null):Operation
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
				var entity:Entity = _options.factory != null ? _options.factory(item) : new _entity();
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
		public function destroy(entities:Array):DestroyRequest
		{
			entities = pendingDestroy(entities);
			return new DestroyRequest(this, entities as Array, function():Operation
			{
				return entities.length > 0 ? createDestroyOperation(entities as Array) : new EmptyOperation();
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
		
		public function insert(entities:Array):InsertRequest
		{
			entities = pendingCreate(entities);
			return new InsertRequest(this, entities as Array, function():Operation
			{
				var toSave:Array = entities as Array;
				return toSave.length > 0 ? createInsertOperation(toSave) : new EmptyOperation();
			});
		}
		
		protected function createInsertOperation(entities:Array):Operation
		{
			throw new IllegalOperationError(reflect.name + " does not support insertion of entities.");
		}
		
		private function havingPropertyChanges(entities:Array):Array
		{
			return entities.filter(function(entity:Entity, ...args):Boolean
			{
				return entity.hasPropertyChanges;
			});
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
				return entity.isPersisted && entity.isDirty;
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
		
		public function save(entities:Array):Request
		{
			return insert(entities).then(update(entities)).then(destroy(entities));
		}
		
		public function saveAll():Request
		{
			return save(_registered.toArray());
		}
		
		public function update(entities:Array):UpdateRequest
		{
			entities = pendingUpdate(entities);
			return new UpdateRequest(this, entities as Array, function():Operation
			{
				var toSave:Array = havingPropertyChanges(entities);
				return toSave.length > 0 ? createUpdateOperation(toSave) : new EmptyOperation();
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
		public function where(options:Object):WhereQueryRequest
		{
			return new WhereQueryRequest(this, deserialize, function():Operation
			{
				return createWhereOperation(options);
			});
		}
		
		protected function createWhereOperation(options:Object):Operation
		{
			throw new IllegalOperationError(reflect.name + " does not support retrieval of entities using where().");
		}
		
		private var _entity:Class;
		/**
		 * The entity type for this service.
		 */
		protected function get entity():Class
		{
			return _entity;
		}
		
		private var _options:Object;
		/**
		 * The options specified for this service.
		 */
		protected function get options():Object
		{
			return _options;
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