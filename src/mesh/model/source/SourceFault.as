package mesh.model.source
{
	/**
	 * The <code>SourceFault</code> class represents an error that occurs in a data source while
	 * attempting to communicate with the backend.
	 * 
	 * @author Dan Schultz
	 */
	public class SourceFault extends Error
	{
		/**
		 * Constructor.
		 * 
		 * @param summary A summary of the fault.
		 * @param details A detailed description of the fault.
		 * @param code A code associated with the fault.
		 */
		public function SourceFault(summary:String, details:String = "", code:String = "")
		{
			super(summary);
			_details = details;
			_code = code;
		}
		
		private var _code:String;
		/**
		 * The fault's code.
		 */
		public function get code():String
		{
			return _code;
		}
		
		private var _details:String;
		/**
		 * A detailed description of the fault.
		 */
		public function get details():String
		{
			return _details;
		}
		
		/**
		 * A short summary of the fault.
		 */
		public function get summary():String
		{
			return message;
		}
	}
}