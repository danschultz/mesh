package mesh.operations
{
	/**
	 * A type of compound operation that executes all of its operations at the same time.
	 * 
	 * @author Dan Schultz
	 */
	public class ParallelOperation extends CompoundOperation
	{
		/**
		 * @copy operations.CompoundOperation#CompoundOperation()
		 */
		public function ParallelOperation(operations:Array = null)
		{
			super(operations);
		}
		
		/**
		 * @inheritDoc
		 */
		override public function during(operation:Operation):Operation
		{
			add(operation);
			return this;
		}
		
		/**
		 * @inheritDoc
		 */
		override protected function startExecution():void
		{
			for each (var operation:Operation in operationSet) {
				executeOperation(operation);
			}
		}
	}
}