package operations
{
	import collections.ArraySet;
	
	import flash.events.Event;
	
	import mx.rpc.Fault;

	/**
	 * A base class for an operation that contains a set of other operations to
	 * execute. There are two types of compound operations: paralleled and chained.
	 * A parallel operation will execute its operations together, where as, a
	 * chained operation will execute each of its operations one at a time, in a 
	 * sequence.
	 * 
	 * <p>
	 * This class only allows the adding and removing of operations when the this 
	 * operation is not executing.
	 * </p>
	 * 
	 * @author Dan Schultz
	 */
	public class CompoundOperation extends Operation
	{
		private var _executingOperations:ArraySet = new ArraySet();
		private var _finishedOperationsCount:int;
		
		/**
		 * Constructor.
		 */
		public function CompoundOperation()
		{
			super();
		}
		
		/**
		 * Adds an operation to the end of the list of operations to execute.
		 * If the operation already exists, it is removed then re-added.
		 * 
		 * @param operation The operation to add.
		 */
		final public function add(operation:Operation):void
		{
			if (!isExecuting) {
				_operations.add(operation);
			}
		}
		
		/**
		 * @inheritDoc
		 */
		final override protected function cancelRequest():void
		{
			super.cancelRequest();
			
			for each (var operation:Operation in _executingOperations) {
				operation.cancel();
			}
		}
		
		/**
		 * @inheritDoc
		 */
		override protected function executeRequest():void
		{
			super.executeRequest();
			_finishedOperationsCount = 0;
		}
		
		/**
		 * Attempts to execute the given operation. If the operation is running it will not
		 * be executed.
		 * 
		 * @param operation The operation to execute.
		 * @throws ArgumentError If the operation does not belong to this compound operation.
		 */
		final protected function executeOperation(operation:Operation):void
		{
			if (!_operations.contains(operation)) {
				throw new ArgumentError(operation + " must belong to this compound operation.");
			}
			
			if (!operation.isExecuting) {
				operation.addEventListener(FinishedOperationEvent.FINISHED, handleOperationFinished);
				operation.addEventListener(FaultOperationEvent.FAULT, handleOperationFault);
				_executingOperations.add(operation);
			}
		}
		
		private function handleOperationFault(event:FaultOperationEvent):void
		{
			fault(event.summary, event.detail);
			cancel();
		}
		
		private function handleOperationFinished(event:FinishedOperationEvent):void
		{
			operationFinished(event.operation);
		}
		
		private function operationFinished(operation:Operation):void
		{
			operation.removeEventListener(FinishedOperationEvent.FINISHED, handleOperationFinished);
			operation.removeEventListener(FaultOperationEvent.FAULT, handleOperationFault);
			
			_executingOperations.remove(operation);
			_finishedOperationsCount++;
			
			// check to see if all the operations are finished.
			if (isExecuting && _finishedOperationsCount == _operations.length) {
				finish(true);
			}
			// get the next operation to execute.
			else {
				
			}
		}
		
		/**
		 * Removes an operation from this operation. The operation will not be removed if
		 * the this operation is currently running.
		 * 
		 * @param operation The operation to remove.
		 */
		final public function remove(operation:Operation):void
		{
			if (!isExecuting) {
				_operations.remove(operation);
			}
		}
		
		private var _operations:ArraySet = new ArraySet();
		/**
		 * The list of <code>Operation</code>s to be executed.
		 */
		protected function get operations():ArraySet
		{
			return _operations;
		}
	}
}