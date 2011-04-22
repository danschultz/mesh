package mesh
{
	public class Name
	{
		public function Name(firstName:String, lastName:String)
		{
			_firstName = firstName;
			_lastName = lastName;
		}
		
		public function equals(name:Name):Boolean
		{
			return firstName == name.firstName && lastName == name.lastName;
		}
		
		private var _firstName:String;
		public function get firstName():String
		{
			return _firstName;
		}
		
		private var _lastName:String;
		public function get lastName():String
		{
			return _lastName;
		}
	}
}