package validations
{
	public class ValidatorResult
	{
		public function ValidatorResult(successful:Boolean, message:String = null)
		{
			_successful = successful;
			_message = message;
		}
		
		private var _successful:Boolean;
		public function get successful():Boolean
		{
			return _successful;
		}
		
		private var _message:String;
		public function get message():String
		{
			return _message;
		}
	}
}