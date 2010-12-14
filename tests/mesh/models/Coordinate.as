package mesh.models
{
	public class Coordinate
	{
		public function Coordinate(latitude:Number, longitude:Number)
		{
			_latitude = latitude;
			_longitude = longitude;
		}
		
		private var _latitude:Number;
		public function get latitude():Number
		{
			return _latitude;
		}
		
		private var _longitude:Number;
		public function get longitude():Number
		{
			return _longitude;
		}
	}
}