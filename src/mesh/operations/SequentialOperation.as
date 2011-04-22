package mesh.operations
{
	/**
	 * A type of compound operation where each operation is executed in a sequence,
	 * and only one operation is permitted to execute at a time.
	 * 
	 * @author Dan Schultz
	 */
	public class SequentialOperation extends CompoundOperation
	{
		/**
		 * @copy operations.CompoundOperation#CompoundOperation()
		 */
		public function SequentialOperation(operations:Array = null)
		{
			super(operations);
		}
		
		/**
		 * @inheritDoc
		 */
		override protected function startExecution():void
		{
			executeOperation(nextOperation(finishedOperationsCount));
		}
		
		/**
		 * @inheritDoc
		 */
		override protected function nextOperation(finishedOperationsCount:int):Operation
		{
			return operationSet.toArray()[finishedOperationsCount];
		}
		
		/**
		 * Adds the given operation to this sequence.
		 * 
		 * @inheritDoc
		 */
		override public function then(operation:Operation):Operation
		{
			add(operation);
			return this;
		}
	}
}