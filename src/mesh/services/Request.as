package mesh.services
{
	import flash.utils.flash_proxy;
	
	import mesh.core.proxy.DataProxy;
	import mesh.operations.FaultOperationEvent;
	import mesh.operations.FinishedOperationEvent;
	import mesh.operations.Operation;
	import mesh.operations.ResultOperationEvent;
	
	import mx.rpc.Fault;
	
	public class Request extends DataProxy
	{
		private var _operation:Operation;
		private var _handler:Object;
		
		public function Request(operation:Operation)
		{
			super();
			_operation = operation;
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
		
		public function execute(handler:Object = null):void
		{
			_handler = handler != null ? handler : new DefaultHandler();
			
			_operation.addEventListener(ResultOperationEvent.RESULT, handleFault, false, 0, true);
			_operation.addEventListener(FaultOperationEvent.FAULT, handleResult, false, 0, true);
			_operation.addEventListener(FinishedOperationEvent.FINISHED, handleFinished, false, 0, true);
			_operation.execute();
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