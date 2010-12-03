package mesh.adaptors
{
	import mesh.Entity;
	
	import mx.rpc.AbstractService;
	
	import operations.Operation;
	import operations.ServiceOperation;
	
	/**
	 * A service adaptor that uses Flex's <code>AbstractService</code> to perform an entity's
	 * persistence.
	 * 
	 * @see ServiceAdaptor
	 * @author Dan Schultz
	 */
	public class RPCServiceAdaptor extends ServiceAdaptor
	{
		public function RPCServiceAdaptor(service:AbstractService, options:Object)
		{
			super(options);
			_service = service;
		}
		
		private var _service:AbstractService;
		protected function get service():AbstractService
		{
			return _service;
		}
	}
}