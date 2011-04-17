package mesh.services
{
	import mesh.core.reflection.newInstance;
	import mesh.operations.Operation;
	import mesh.operations.ServiceOperation;
	
	import mx.rpc.AbstractService;
	
	/**
	 * A service adaptor that uses Flex's <code>AbstractService</code> to perform an entity's
	 * persistence.
	 * 
	 * <p>
	 * Any options that are defined on the <code>[ServiceAdaptor]</code> metadata or passed to 
	 * the constructor, will tried to be set on the adaptor's service.
	 * 
	 * <p>
	 * <strong>Example:</strong> Setting the busy cursor for the service.
	 * <pre listing="3.0">
	 * [ServiceAdaptor(showBusyCursor="true")]
	 * </pre>
	 * </p>
	 * </p>
	 * 
	 * @see http://help.adobe.com/en_US/FlashPlatform/reference/actionscript/3/mx/rpc/AbstractService.html AbstractService
	 * @author Dan Schultz
	 */
	public class RPCService extends Service
	{
		public function RPCService(service:AbstractService, factory:Function)
		{
			super(factory);
		}
		
		/**
		 * The first argument is a string representing the name of the service to call. All arguments
		 * after the name will be passed as arguments to the service operation.
		 * 
		 * @inheritDoc
		 */
		override protected function createOperation(...args):Operation
		{
			return newInstance.apply(null, [ServiceOperation, _service].concat(args));
		}
		
		private var _service:AbstractService;
		/**
		 * The service for this adaptor.
		 */
		protected function get service():AbstractService
		{
			return _service;
		}
	}
}