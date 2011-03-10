package operations
{
	import mx.rpc.AbstractService;
	import mx.rpc.AsyncResponder;
	import mx.rpc.AsyncToken;
	import mx.rpc.events.FaultEvent;
	import mx.rpc.events.ResultEvent;

	/**
	 * An asynchronous operation that wraps the execution of a Flex RPC service. This operation
	 * can be used with either <code>HTTPMultiService</code>s or <code>RemoteObject</code>s.
	 * 
	 * @author Dan Schultz
	 */
	public class ServiceOperation extends NetworkOperation
	{
		private var _service:AbstractService;
		private var _name:String;
		private var _args:Array;
		
		/**
		 * Constructor.
		 * 
		 * @param service The service to execute the operation.
		 * @param name The name of the operation to execute.
		 * @param args A list of arguments to pass to the operation.
		 */
		public function ServiceOperation(service:AbstractService, name:String, ... args)
		{
			super();
			_service = service;
			_name = name;
			_args = args;
		}
		
		/**
		 * @inheritDoc
		 */
		override protected function request():void
		{
			super.request();
			
			var token:AsyncToken = _service.getOperation(_name).send.apply(null, _args);
			token.addResponder(new AsyncResponder(handleAsyncTokenResult, handleAsyncTokenFault, token));
		}
		
		private function handleAsyncTokenResult(event:ResultEvent, token:AsyncToken):void
		{
			result(event.result);
		}
		
		private function handleAsyncTokenFault(event:FaultEvent, token:AsyncToken):void
		{
			fault(event.fault.faultString, event.fault.faultDetail, event.fault.faultCode);
		}
	}
}