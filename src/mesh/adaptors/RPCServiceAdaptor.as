package mesh.adaptors
{
	import mx.rpc.AbstractService;
	
	/**
	 * A service adaptor that uses Flex's <code>AbstractService</code> to perform an entity's
	 * persistence.
	 * 
	 * @see ServiceAdaptor
	 * @author Dan Schultz
	 */
	public class RPCServiceAdaptor extends ServiceAdaptor
	{
		/**
		 * Constructor.
		 * 
		 * @param service The service for this adaptor.
		 * @param options An options hash to configure the adaptor.
		 */
		public function RPCServiceAdaptor(service:AbstractService, options:Object)
		{
			super(options);
			_service = service;
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