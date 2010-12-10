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
		 * @param entity The entity who owns this service adaptor.
		 * @param options An options hash to configure the adaptor.
		 */
		public function RPCServiceAdaptor(service:AbstractService, entity:Class, options:Object)
		{
			super(entity, options);
			
			_service = service;
			
			if (_service.hasOwnProperty("showBusyCursor")) {
				_service.showBusyCursor = options.hasOwnProperty("showBusyCursor") ? Boolean( options.showBusyCursor ) : false;
			}
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