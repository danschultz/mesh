package operations
{
	/**
	 * An synchronous operation that calls a method on an object. The data returned
	 * from the method call will be passed to the <code>ResultOperationEvent.data</code>
	 * property. If an error is thrown during the execution of the method, the operation
	 * will fault and dispatch the <code>FaultOperationEvent.FAULT</code> event.
	 * 
	 * <p>
	 * <strong>Using a method operation:</strong>
	 * 
	 * <listing version="3.0">
	 * var str:String = "Hello World";
	 * var operation:MethodOperation = new MethodOperation(str.substr, 0, 5);
	 * operation.addEventListener(ResultOperationEvent.RESULT, handleOperationResult);
	 * operation.execute();
	 * 
	 * function handleOperationResult(event:ResultOperationEvent):void
	 * {
	 * 	trace(event.data); // Hello
	 * }
	 * </listing>
	 * </p>
	 * 
	 * @author Dan Schultz
	 */
	public class MethodOperation extends Operation
	{
		private var _func:Function;
		private var _args:Array;
		
		/**
		 * Constructor.
		 * 
		 * @param func The function to execute.
		 * @param args Arguments to pass to the function when the operation is executed.
		 */
		public function MethodOperation(func:Function, ... args)
		{
			super();
			_func = func;
			_args = args;
		}
		
		/**
		 * @inheritDoc
		 */
		override protected function executeRequest():void
		{
			try {
				result(_func.apply(null, _args));
			} catch (e:Error) {
				fault(e.toString(), e.getStackTrace());
			}
		}
	}
}