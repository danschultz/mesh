package mesh.model.source
{
	import mesh.core.reflection.newInstance;
	import mesh.operations.ServiceOperation;
	
	import mx.rpc.AbstractService;

	/**
	 * A base class for HTTP, SOAP, and AMF data sources.
	 * 
	 * @author Dan Schultz
	 */
	public class RPCSource extends Source
	{
		private var _service:AbstractService;
		
		/**
		 * Constructor.
		 * 
		 * @param service The service to use when making service calls.
		 */
		public function RPCSource(service:AbstractService)
		{
			super();
			_service = service;
		}
		
		/**
		 * Used by sub-classes to create a service operation that encapsulates the service call. This operation
		 * and can be modified to include retry attempts and timeouts.
		 * 
		 * @param method The service method to invoke.
		 * @param args The arguments to the service method.
		 * @return An unexecuted service operation.
		 * 
		 * @see mesh.operations.ServiceOperation
		 */
		protected function createOperation(method:String, ...args):ServiceOperation
		{
			return newInstance.apply(null, [ServiceOperation, _service, method].concat(args));
		}
	}
}