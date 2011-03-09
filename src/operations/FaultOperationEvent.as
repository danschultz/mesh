package operations
{
	import flash.events.Event;
	
	/**
	 * An event dispatched by an operation to indicate that an error or fault
	 * has occurred during its execution.
	 * 
	 * @author Dan Schultz
	 */
	public class FaultOperationEvent extends OperationEvent
	{
		/**
		 * An event type for when an operation has errored or faulted during execution.
		 */
		public static const FAULT:String = "fault";
		
		/**
		 * Constructor.
		 * 
		 * @param summary A simple description of the fault.
		 * @param detail A detailed description of the fault.
		 */
		public function FaultOperationEvent(summary:String, detail:String = "", code:String = "")
		{
			super(FAULT);
			
			_summary = summary == null ? "" : summary;
			_detail = detail == null ? "" : detail;
			_code = code == null ? "" : code;
		}
		
		/**
		 * @private
		 */
		override public function clone():Event
		{
			return new FaultOperationEvent(summary, detail);
		}
		
		private var _summary:String;
		/**
		 * A simple description of the fault.
		 */
		public function get summary():String
		{
			return _summary;
		}
		
		private var _detail:String;
		/**
		 * A detailed description of the fault.
		 */
		public function get detail():String
		{
			return _detail;
		}
		
		private var _code:String;
		/**
		 * A specific code given to the fault.
		 */
		public function get code():String
		{
			return _code;
		}
	}
}