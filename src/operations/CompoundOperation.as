package operations
{
	import collections.ArraySet;
	
	import flash.events.Event;

	/**
	 * A base class for an operation that contains a set of other operations to
	 * execute. There are two types of compound operations: paralleled and chained.
	 * A parallel operation will execute its operations together, where as, a
	 * chained operation will execute each of its operations one at a time, in a 
	 * sequence.
	 * 
	 * <p>
	 * This class only allows the addition and removal of operations when the the
	 * compound operation is not executing.
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
		public function add(operation:Operation):void
		{
			if (!isExecuting) {
				remove(operation);
				_operations.add(operation);
			}
		}
		
		protected function executeOperation(operation:Operation):void
		{
			if (!operation.isExecuting) {
				operation.addEventListener(FinishedOperationEvent.FINISHED, handleOperationFinished);
				operation.addEventListener(FaultOperationEvent.FAULT, handleOperationFault);
				_executingOperations.add(operation);
			}
		}
		
		private function handleOperationFault(event:FaultOperationEvent):void
		{
			// TODO Auto-generated method stub
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
		}
		
		/**
		 * Removes an operation from this operation.
		 * 
		 * @param operation The operation to remove.
		 */
		public function remove(operation:Operation):void
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