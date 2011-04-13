package mesh.services
{
	import flash.utils.flash_proxy;
	
	import mesh.adaptors.ServiceAdaptor;
	import mesh.core.proxy.DataProxy;
	import mesh.operations.FaultOperationEvent;
	import mesh.operations.FinishedOperationEvent;
	import mesh.operations.Operation;
	import mesh.operations.ResultOperationEvent;
	
	import mx.rpc.Fault;
	
	public class Request extends DataProxy
	{
		private var _block:Function;
		private var _adaptor:ServiceAdaptor;
		private var _handler:Object;
		private var _operation:Operation;
		
		public function Request(adaptor:ServiceAdaptor, block:Function)
		{
			super();
			_adaptor = adaptor;
			_block = block;
		}
		
		private function handleFault(event:FaultOperationEvent):void
		{
			_handler.fault(new Fault(event.code, event.summary, event.detail));
		}
		
		private function handleResult(event:ResultOperationEvent):void
		{
			flash_proxy::object = _handler.parse(event.data);
		}
		
		private function handleFinished(event:FinishedOperationEvent):void
		{
			if (event.successful) {
				_handler.success();
			}
		}
		
		protected function executeBlock(block:Function, adaptor:ServiceAdaptor):Operation
		{
			return block(adaptor);
		}
		
		public function execute(handler:Object = null):void
		{
			_handler = handler != null ? handler : new DefaultHandler();
			
			if (_operation == null) {
				_operation = executeBlock(_block, _adaptor);
				_operation.addEventListener(ResultOperationEvent.RESULT, handleFault, false, 0, true);
				_operation.addEventListener(FaultOperationEvent.FAULT, handleResult, false, 0, true);
				_operation.addEventListener(FinishedOperationEvent.FINISHED, handleFinished, false, 0, true);
			}
			
			if (!_operation.isExecuting) {
				_operation.execute();
			}
		}
		
		public function during(request:Request):Request
		{
			return new CompoundRequest();
		}
		
		public function then(request:Request):Request
		{
			return new CompoundRequest();
		}
	}
}

import mx.rpc.Fault;

class DefaultHandler
{
	public function fault(fault:Fault):void
	{
		
	}
	
	public function parse(data:Object):Object
	{
		return data;
	}
	
	public function success():void
	{
		
	}
}