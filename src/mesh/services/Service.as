package mesh.services
{
	import collections.HashSet;
	
	import flash.errors.IllegalOperationError;
	import flash.utils.setTimeout;
	
	import mesh.Entity;
	import mesh.Mesh;
	import mesh.adaptors.ServiceAdaptor;
	import mesh.core.array.flatten;
	import mesh.core.reflection.Type;
	import mesh.core.string.capitalize;
	import mesh.operations.EmptyOperation;
	import mesh.operations.FactoryOperation;
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
		
		/**
		 * Constructor.
		 */
		public function Service()
		{
			
		}
		
		/**
		 * Generates an operation to retrieve all entities of a certain type from the backend.
		 * 
		 * @param options Any options to query with.
		 * @return An unexecuted operation.
		 */
		public function all(options:Object = null):Operation
		{
			throw new IllegalOperationError(reflect.name + " does not support retrieval of entities using all()");
		}
		
		private function createOperation(entities:Array, factory:Function, callback:String):Operation
		{
			callback = capitalize(callback);
			
			var before:Operation = new EmptyOperation();
			var after:Operation = new EmptyOperation();
			for each (var entity:Entity in entities) {
				before = before.then(new FactoryOperation(entity.callback, "before" + callback));
				after = after.then(new FactoryOperation(entity.callback, "after" + callback));
			}
			
			return before.then(factory(entities)).then(after);
		}
		
		protected function createDestroy(entities:Array):Operation
		{
			throw new IllegalOperationError(reflect.name + " does not support destruction of entities.");
		}
		
		protected function createInsert(entities:Array):Operation
		{
			throw new IllegalOperationError(reflect.name + " does not support insertion of entities.");
		}
		
		protected function createUpdate(entities:Array):Operation
		{
			throw new IllegalOperationError(reflect.name + " does not support updating of entities.");
		}
		
		/**
		 * Marks the given entities to be destroyed the next time this service is saved.
		 * 
		 * @param entities The entities to destroy.
		 */
		public function destroy(entities:Object):void
		{
			for each (var entity:Entity in flatten(entities)) {
				if (_registered.contains(entity)) {
					entity.markForRemoval();
				}
			}
		}
		
		/**
		 * Generates an operation that retrieves a list of entities with the given IDs.
		 * 
		 * @param ids The IDs of the objects to retrieve.
		 * @return An unexecuted operation.
		 */
		public function find(ids:Array):Operation
		{
			throw new IllegalOperationError(reflect.name + " does not support retrieval of entities using find()");
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
				return !entity.isPersisted && entity.hasPropertyChanges;
			});
		}
		
		/**
		 * Registers the given entities to this service. If the entity is new, it will be created
		 * on this service's next save. Otherwise, if the entity is persisted, it will be updated.
		 * 
		 * @param entities The list of entities to create and register.
		 */
		public function register(entities:Object):void
		{
			_registered.addAll(flatten(entities));
		}
		
		public function save(entities:Object, validate:Boolean = true):Operation
		{
			var toSave:Array = flatten(entities);
			var toInsert:Array = pendingCreate(toSave);
			var toUpdate:Array = pendingUpdate(toSave);
			var toDestroy:Array = pendingDestroy(toSave);
			
			var operation:Operation = new EmptyOperation();
			if (toInsert.length > 0) {
				operation = operation.then(createOperation(toInsert, createInsert, "save"));
			}
			if (toUpdate.length > 0) {
				operation = operation.then(createOperation(toUpdate, createUpdate, "save"));
			}
			if (toDestroy.length > 0) {
				operation = operation.then(createOperation(toDestroy, createDestroy, "destroy"));
			}
			setTimeout(operation.execute, Mesh.DELAY);
			return operation;
		}
		
		public function saveAll(validate:Boolean = true):Operation
		{
			return save(_registered.toArray(), validate);
		}
		
		/**
		 * Generates an operation that retrieves a list of entities using an options hash.
		 * 
		 * @param options The options to limit the retrieval.
		 * @return An unexecuted operation.
		 */
		public function where(options:Object):Operation
		{
			throw new IllegalOperationError(reflect.name + " does not support retrieval of entities using where()");
		}
		
		private var _adaptor:ServiceAdaptor;
		/**
		 * The adaptor for this service that generates operations based on the application's
		 * current environment.
		 */
		public function get adaptor():ServiceAdaptor
		{
			return _adaptor;
		}
		public function set adaptor(value:ServiceAdaptor):void
		{
			_adaptor = value;
		}
		
		private var _reflect:Type;
		/**
		 * A reflection object for this service.
		 */
		public function get reflect():Type
		{
			if (_reflect == null) {
				_reflect = Type.reflect(this);
			}
			return _reflect;
		}
	}
}