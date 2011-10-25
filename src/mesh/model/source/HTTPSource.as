package mesh.model.source
{
	import mesh.core.object.copy;
	import mesh.operations.ServiceOperation;
	
	import mx.rpc.AbstractService;
	import mx.rpc.http.HTTPMultiService;
	import mx.rpc.http.Operation;
	
	public class HTTPSource extends RPCSource
	{
		private var _service:HTTPMultiService;
		
		/**
		 * Constructor.
		 */
		public function HTTPSource()
		{
			_service = new HTTPMultiService();
			super(_service);
			configure(_service);
		}
		
		/**
		 * Called during creation to allow sub-classes to configure the service.
		 * 
		 * @param service The source's service.
		 */
		protected function configure(service:HTTPMultiService):void
		{
			
		}
		
		/**
		 * The first argument is a URL string which represents the REST operation to call. The second
		 * argument is an optional object to pass to the operation. The third argument is an optional
		 * object who's values will be copied to the <code>mx.rpc.http.Operation</code> which is 
		 * generated from this function.
		 * 
		 * @inheritDoc
		 */
		override protected function createOperation(url:String, ...args):ServiceOperation
		{
			if (_service.operations == null || _service.operations[url] == null) {
				var operation:Operation = createHTTPOperation(url, args[1]);
				_service.operationList = _service.operationList != null ? _service.operationList.concat(operation) : [operation];
			}
			
			if (args.length > 1) {
				args = args.slice(0, 1);
			}
			
			return super.createOperation.apply(null, [url].concat(args));
		}
		
		private function createHTTPOperation(url:String, options:Object = null):Operation
		{
			var operation:Operation = new Operation();
			operation.name = url;
			operation.url = url;
			
			if (options != null) {
				copy(options, operation);
			}
			
			return operation;
		}
	}
}