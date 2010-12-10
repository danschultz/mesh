package mesh.callbacks
{
	import operations.MethodOperation;
	import operations.Operation;

	/**
	 * A synchronous operation that executes a callback function and allows sub-classes
	 * to handle the functions response.
	 * 
	 * @author Dan Schultz
	 */
	public class CallbackOperation extends MethodOperation
	{
		/**
		 * Constructor.
		 * 
		 * @param callback The callback to execute.
		 */
		public function CallbackOperation(callback:Function)
		{
			super(callback);
		}
	}
}