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
			throw new IllegalOperationError(reflect.name + " does not support retrieval of entities using all()");
		}
		
		public function belongingTo(entity:Entity):ListQueryRequest
		{
			throw new IllegalOperationError(reflect.name + " does not support retrieval of entities belonging to " + entity);
		}
		
		public function create(clazz:Class):*
		{
			if (clazz is Entity) {
				var instance:Entity = new clazz();
				register(instance);
				return instance;
			}
			throw new ArgumentError("Expected class to be an Entity");
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
			return createDestroy(pendingDestroy(flatten(entities)));
		}
		
		protected function createDestroy(entities:Array):DestroyRequest
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
		
		public function findOne(id:*):QueryRequest
		{
			throw new IllegalOperationError(reflect.name + " does not support retrieval of entities using findOne().");
		}
		
		public function findMany(...ids):ListQueryRequest
		{
			throw new IllegalOperationError(reflect.name + " does not support retrieval of entities using findMany().");
		}
		
		public function insert(entities:Object):InsertRequest
		{
			return createInsert(pendingCreate(flatten(entities)));
		}
		
		protected function createInsert(entities:Array):InsertRequest
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
			return createUpdate(pendingUpdate(flatten(entities)));
		}
		
		protected function createUpdate(entities:Array):UpdateRequest
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