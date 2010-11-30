package validations
{
	/**
	 * A class that is returned from a validation to indicate that a validation
	 * failed.
	 * 
	 * @author Dan Schultz
	 */
	public class ValidationError
	{
		/**
		 * Constructor.
		 * 
		 * @param message The message for the error.
		 */
		public function ValidationError(message:String)
		{
			_message = message;
		}
		
		/**
		 * @private
		 */
		public function toString():String
		{
			return message;
		}
		
		private var _message:String;
		/**
		 * The error message for the validation.
		 */
		public function get message():String
		{
			return _message;
		}
	}
}