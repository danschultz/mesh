package mesh.services
{
	import flash.errors.IllegalOperationError;
	
	import mesh.core.reflection.Type;
	import mesh.operations.Operation;
	
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
		 */
		public function ServiceAdaptor(options:Object = null)
		{
			_options = options == null ? {} : options;
		}
		
		/**
		 * Generates an operation that is specific for this service adaptor.
		 * 
		 * @param args The args to pass to the constructor of the operation.
		 * @return A new unexecuted operation.
		 */
		public function createOperation(...args):Operation
		{
			throw new IllegalOperationError(reflect.name + ".createOperation() is not implemented.");
		}
		
		protected function deserialize(entities:Array):Array
		{
			return entities.concat();
		}
		
		protected function serialize(entities:Array):Array
		{
			return entities.concat();
		}
		
		private var _options:Object;
		/**
		 * A set of options to configure this service adaptor.
		 */
		protected function get options():Object
		{
			return _options;
		}
		
		private var _reflect:Type;
		/**
		 * A reflection on this object.
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