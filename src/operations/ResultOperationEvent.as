package operations
{
	import flash.events.Event;
	
	/**
	 * An event dispatched by an operation to indicate that a result was received
	 * during its execution.
	 * 
	 * @author Dan Schultz
	 */
	public class ResultOperationEvent extends OperationEvent
	{
		/**
		 * An event type for when an operation has received a result during execution.
		 */
		public  static const RESULT:String = "result";
		
		/**
		 * Constructor.
		 * 
		 * @param data The parsed result's data.
		 */
		public function ResultOperationEvent(data:Object)
		{
			super(RESULT);
			_data = data;
		}
		
		/**
		 * @private
		 */
		override public function clone():Event
		{
			return new ResultOperationEvent(data);
		}
		
		private var _data:Object;
		/**
		 * The parsed result's data.
		 */
		public function get data():Object
		{
			return _data;
		}
	}
}