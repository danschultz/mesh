package mesh
{
	public class Name
	{
		public function Name(first:String, last:String)
		{
			_first = first;
			_last = last;
		}
		
		public function equals(name:Name):Boolean
		{
			return first == name.first && last == name.last;
		}
		
		private var _first:String;
		public function get first():String
		{
			return _first;
		}
		
		private var _last:String;
		public function get last():String
		{
			return _last;
		}
	}
}