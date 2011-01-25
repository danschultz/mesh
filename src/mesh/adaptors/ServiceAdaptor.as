package mesh.adaptors
{
	import flash.errors.IllegalOperationError;
	
	import mesh.Entity;
	import mesh.associations.Relationship;
	import mesh.core.reflection.className;
	
	import operations.Operation;
	
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
		public function ServiceAdaptor(entity:Class, options:Object = null)
		{
			_entity = entity;
			_options = options == null ? {} : options;
		}
		
		/**
		 * Generates an operation to retrieve all entities of a certain type from the backend.
		 * 
		 * @param options Any options to query with.
		 * @return An unexecuted operation.
		 */
		public function all(options:Object = null):Operation
		{
			throw new IllegalOperationError(className(this) + " does not support retrieval of entities using all()");
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
		 * @param entities The list of entities to create.
		 * @return An unexecuted operation.
		 */
		public function create(entities:Array):Operation
		{
			throw new IllegalOperationError(className(this) + " does not support creation of entities");
		}
		
		/**
		 * Generates an operation to destroy an entity in the backend.
		 * 
		 * @param entities The entities to destroy.
		 * @return An unexecuted operation.
		 */
		public function destroy(entities:Array):Operation
		{
			throw new IllegalOperationError(className(this) + " does not support destruction of entities");
		}
		
		/**
		 * Generates an operation that retrieves a list of entities with the given IDs.
		 * 
		 * @param ids The IDs of the objects to retrieve.
		 * @return An unexecuted operation.
		 */
		public function find(ids:Array):Operation
		{
			throw new IllegalOperationError(className(this) + " does not support retrieval of entities using find()");
		}
		
		/**
		 * Generates an operation to retrieve with a given set of options from the backend.
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
		 * @param entities The list of entities to update.
		 * @return An unexecuted operation.
		 */
		public function update(entities:Array):Operation
		{
			throw new IllegalOperationError(className(this) + " does not support updating of entities");
		}
		
		/**
		 * Generates an operation that retrieves a list of entities using an options hash.
		 * 
		 * @param options The options to limit the retrieval.
		 * @return An unexecuted operation.
		 */
		public function where(options:Object):Operation
		{
			throw new IllegalOperationError(className(this) + " does not support retrieval of entities using where()");
		}
		
		/**
		 * Generates an operation that is specific for this service adaptor.
		 * 
		 * @param args The args to pass to the constructor of the operation.
		 * @return A new unexecuted operation.
		 */
		protected function generateOperation(...args):Operation
		{
			throw new IllegalOperationError(className(this) + " does not support generateOperation()");
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