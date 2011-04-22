package mesh.operations
{
	/**
	 * An operation that when executed will finish immediately. This operation is useful
	 * as a <code>null</code> object.
	 * 
	 * @author Dan Schultz
	 */
	public class EmptyOperation extends Operation
	{
		/**
		 * Constructor.
		 */
		public function EmptyOperation()
		{
			super();
		}
		
		/**
		 * @inheritDoc
		 */
		override protected function executeRequest():void
		{
			finish(true);
		}
	}
}