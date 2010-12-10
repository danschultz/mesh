package mesh.adaptors
{
	import flash.errors.IllegalOperationError;
	
	import mesh.Entity;
	import mesh.associations.Relationship;
	
	import operations.Operation;
	
	import reflection.className;
	
	/**
	 * A service adaptor represents the required strategy for an entity to be persisted and
	 * retrieved from some backend service.
	 * 
	 * @author Dan Schultz
	 */
	public class ServiceAdaptor
	{
		/**
		 * Constructor.
		 * 
		 * @param entity The entity for this service adaptor.
		 * @param options A set of options to configure this service adaptor.
		 */
		public function ServiceAdaptor(entity:Class, options:Object)
		{
			_entity = entity;
			_options = options;
		}
		
		/**
		 * Generates an operation to retrieve the entities belonging to a parent entity.
		 * 
		 * @param entity The parent entity to query with.
		 * @return An unexecuted operation.
		 */
		public function belongingTo(entity:Entity, relationship:Relationship):Operation
		{
			throw new IllegalOperationError(className(this) + " does not support retrieval of relationship '" + relationship + "'");
		}
		
		/**
		 * Generates an operation to create an entity in the backend.
		 * 
		 * @param entity The entity to create.
		 * @return An unexecuted operation.
		 */
		public function create(entity:Entity):Operation
		{
			throw new IllegalOperationError(className(this) + " does not support creation of entities");
		}
		
		/**
		 * Generates an operation to destroy an entity in the backend.
		 * 
		 * @param entity The entity to destroy.
		 * @return An unexecuted operation.
		 */
		public function destroy(entity:Entity):Operation
		{
			throw new IllegalOperationError(className(this) + " does not support destruction of entities");
		}
		
		/**
		 * Generates an operation to retrieve with a given set of options, from the backend.
		 * 
		 * @param options The options used to query and retrieve the entity.
		 * @return An unexecuted operation.
		 */
		public function retrieve(options:Object):Operation
		{
			throw new IllegalOperationError(className(this) + " does not support retrieval of entities");
		}
		
		/**
		 * Generates an operation to update an entity and its properties in the backend.
		 * 
		 * @param entity The entity to update.
		 * @return An unexecuted operation.
		 */
		public function update(entity:Entity):Operation
		{
			throw new IllegalOperationError(className(this) + " does not support updating of entities");
		}
		
		private var _entity:Class;
		/**
		 * The entity that this service adaptor belongs to.
		 */
		protected function get entity():Class
		{
			return _entity;
		}
		
		private var _options:Object;
		/**
		 * A set of options to configure this service adaptor.
		 */
		protected function get options():Object
		{
			return _options;
		}
	}
}