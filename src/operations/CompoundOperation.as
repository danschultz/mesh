package operations
{
	import collections.HashSet;
	
	import flash.errors.IllegalOperationError;

	/**
	 * A base class for an operation that contains a set of other operations to
	 * execute. There are two types of compound operations: parallel and chained.
	 * A parallel operation will execute its operations together, where as, a
	 * chained operation will execute each of its operations one at a time, in a 
	 * sequence.
	 * 
	 * <p>
	 * This class only allows the adding and removing of operations when the this 
	 * operation is not executing.
	 * </p>
	 * 
	 * <p>
	 * If an operation belonging to this operation fails, this operation will cancel
	 * all remaining operations and dispatch an unsuccessful
	 * <code>FinishedOperationEvent.FINISHED</code> event. Clients that need to respond
	 * to the operation's fault, should add fault listeners to the individual commands.
	 * </p>
	 * 
	 * <p>
	 * Clients shouldn't need to work with this class directly. All operations have
	 * a <code>Operation.during()</code> and <code>Operation.then()</code> methods
	 * that can be used for combining operations.
	 * </p>
	 * 
	 * @see operations.Operation#during()
	 * @see operations.Operation#then()
	 * 
	 * @author Dan Schultz
	 */
	public class CompoundOperation extends Operation
	{
		private var _executingOperations:HashSet = new HashSet();
		
		/**
		 * Constructor.
		 * 
		 * @param operations A set of <code>Operation</code>s that this operation will 
		 * 	execute.
		 */
		public function CompoundOperation(operations:Array = null)
		{
			super();
			_operations.addAll(operations);
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
				_operations.add(operation);
			}
		}
		
		/**
		 * @inheritDoc
		 */
		override protected function cancelRequest():void
		{
			super.cancelRequest();
			
			for each (var operation:Operation in _executingOperations) {
				operation.removeEventListener(FinishedOperationEvent.FINISHED, handleOperationFinished);
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
			
			if (operationSet.isEmpty) {
				finish(true);
			} else {
				startExecution();
			}
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
			if (operation == null) {
				throw new ArgumentError("Cannot execute null operation.");
			}
			
			if (!_operations.contains(operation)) {
				throw new ArgumentError(operation + " must belong to this compound operation.");
			}
			
			if (!operation.isExecuting) {
				operation.addEventListener(FinishedOperationEvent.FINISHED, handleOperationFinished);
				operation.addEventListener(FaultOperationEvent.FAULT, handleOperationFault);
				_executingOperations.add(operation);
				operation.execute();
			}
		}
		
		private function handleOperationFault(event:FaultOperationEvent):void
		{
			fault(event.summary, event.detail);
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
			progressed(_finishedOperationsCount);
			
			// check to see if all the operations are finished.
			if (isExecuting && _finishedOperationsCount == _operations.length) {
				finish(true);
			}
			// get the next operation to execute.
			else {
				var nextOperation:Operation = nextOperation(_finishedOperationsCount);
				if (nextOperation != null) {
					executeOperation(nextOperation);
				}
			}
		}
		
		/**
		 * Determines the next operation to be executed. If no operations are left to execute,
		 * this method should return <code>null</code>.
		 * 
		 * @param finishedOperationsCount The number of operations that have finished.
		 * @return The next operation to execute, or <code>null</code> no operations are left.
		 */
		protected function nextOperation(finishedOperationsCount:int):Operation
		{
			return null;
		}
		
		/**
		 * Removes an operation from this operation. The operation will not be removed if
		 * the this operation is currently running.
		 * 
		 * @param operation The operation to remove.
		 */
		public function remove(operation:Operation):void
		{
			if (!isExecuting) {
				_operations.remove(operation);
			}
		}
		
		/**
		 * Called when the client requests that the compound operation be executed, and the
		 * operation contains other operations to execute.
		 */
		protected function startExecution():void
		{
			throw new IllegalOperationError("CompoundOperation.startExecution() must be implemented.");
		}
		
		private var _finishedOperationsCount:int;
		/**
		 * The number of operations that have finished.
		 */
		protected function get finishedOperationsCount():int
		{
			return _finishedOperationsCount;
		}
		
		private var _operations:HashSet = new HashSet();
		/**
		 * The list of <code>Operation</code>s to be executed.
		 */
		protected function get operationSet():HashSet
		{
			return _operations;
		}
		
		/**
		 * @inheritDoc
		 */
		override protected function get unitsTotal():Number
		{
			return operationSet.length;
		}
	}
}
