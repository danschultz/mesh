package mesh.adaptors
{
	import mesh.Entity;
	
	import mx.rpc.AbstractService;
	
	import operations.EmptyOperation;
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
		 * @param options A set of options to configure this service adaptor.
		 */
		public function ServiceAdaptor(options:Object)
		{
			_options = options;
		}
		
		/**
		 * Generates an operation to create an entity in the backend.
		 * 
		 * @param entity The entity to create.
		 * @return An unexecuted operation.
		 */
		public function create(entity:Entity):Operation
		{
			return new EmptyOperation();
		}
		
		/**
		 * Generates an operation to destroy an entity in the backend.
		 * 
		 * @param entity The entity to destroy.
		 * @return An unexecuted operation.
		 */
		public function destroy(entity:Entity):Operation
		{
			return new EmptyOperation();
		}
		
		/**
		 * Generates an operation to retrieve with a given set of options, from the backend.
		 * 
		 * @param options The options used to query and retrieve the entity.
		 * @return An unexecuted operation.
		 */
		public function retrieve(options:Object):Operation
		{
			return new EmptyOperation();
		}
		
		/**
		 * Generates an operation to update an entity and its properties in the backend.
		 * 
		 * @param entity The entity to update.
		 * @return An unexecuted operation.
		 */
		public function update(entity:Entity):Operation
		{
			return new EmptyOperation();
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