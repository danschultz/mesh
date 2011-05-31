package mesh.services
{
	import mesh.operations.MethodOperation;
	import mesh.operations.Operation;

	/**
	 * A request the executes a block function. The request's result will be the data
	 * that the block returns. If the block throws an error, the request will fault with
	 * that error.
	 * 
	 * @author Dan Schultz
	 */
	public class SynchronousRequest extends OperationRequest
	{
		/**
		 * @copy Request#Request()
		 */
		public function SynchronousRequest(block:Function = null)
		{
			super(function():Operation
			{
				return new MethodOperation(block);
			});
		}
	}
}