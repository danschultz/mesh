package mesh.operations
{
	import flash.events.Event;
	
	import mx.rpc.events.ResultEvent;

	/**
	 * An operation that wraps a factory method that generates an operation that this
	 * operation will invoke.
	 * 
	 * @author Dan Schultz
	 */
	public class FactoryOperation extends Operation
	{
		private var _factory:Function;
		private var _operation:Operation;
		private var _args:Array;
		
		private var _faultEvent:FaultOperationEvent;
		private var _resultEvent:ResultOperationEvent;
		
		/**
		 * Constructor.
		 * 
		 * @param factory The factory method that will return an operation to execute.
		 * @param args The arguments to pass to the factory method.
		 */
		public function FactoryOperation(factory:Function, ...args)
		{
			super();
			_factory = factory;
			_args = args;
		}
		
		/**
		 * @inheritDoc
		 */
		override protected function cancelRequest():void
		{
			super.cancelRequest();
			_operation.cancel();
		}
		
		/**
		 * @inheritDoc
		 */
		override protected function executeRequest():void
		{
			super.executeRequest();
			
			_faultEvent = null;
			_resultEvent = null;
			
			_operation = _factory.apply(null, _args);
			_operation.addEventListener(FaultOperationEvent.FAULT, handleFault);
			_operation.addEventListener(ResultOperationEvent.RESULT, handleResult);
			_operation.addEventListener(FinishedOperationEvent.FINISHED, handleFinished);
			_operation.execute();
		}
		
		private function handleFault(event:FaultOperationEvent):void
		{
			_faultEvent = event;
		}
		
		private function handleResult(event:ResultOperationEvent):void
		{
			_resultEvent = event;
		}
		
		private function handleFinished(event:FinishedOperationEvent):void
		{
			if (_faultEvent != null) {
				fault(_faultEvent.summary, _faultEvent.detail);
			} else if (_resultEvent != null) {
				result(_resultEvent.data);
			} else {
				finish(event.successful);
			}
		}
	}
}