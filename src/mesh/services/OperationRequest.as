package mesh.services
{
	import mesh.adaptors.ServiceAdaptor;
	import mesh.operations.FaultOperationEvent;
	import mesh.operations.FinishedOperationEvent;
	import mesh.operations.Operation;
	import mesh.operations.ResultOperationEvent;
	
	import mx.rpc.Fault;
	import mx.rpc.events.FaultEvent;
	
	public class OperationRequest extends Request
	{
		private var _operation:Operation;
		
		public function OperationRequest(block:Function)
		{
			super(block);
		}
		
		private function handleFault(event:FaultOperationEvent):void
		{
			fault(new Fault(event.code, event.summary, event.detail));
		}
		
		private function handleResult(event:ResultOperationEvent):void
		{
			result(event.data);
		}
		
		private function handleFinished(event:FinishedOperationEvent):void
		{
			if (event.successful) {
				finished();
			}
		}
		
		override protected function executeBlock(block:Function):void
		{
			if (_operation == null) {
				_operation = block.apply(null, blockArgs());
				_operation.addEventListener(FaultOperationEvent.FAULT, handleFault);
				_operation.addEventListener(ResultOperationEvent.RESULT, handleResult);
				_operation.addEventListener(FinishedOperationEvent.FINISHED, handleFinished);
			}
			
			if (!_operation.isExecuting) {
				_operation.execute();
			}
		}
	}
}