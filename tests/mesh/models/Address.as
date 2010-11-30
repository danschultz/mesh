package mesh.models
{
	public class Address
	{
		public function Address(street:String, city:String)
		{
			_street = street;
			_city = city;
		}
		
		public function equals(address:Address):Boolean
		{
			return street == address.street &&
				   city == address.city;
		}
		
		private var _street:String;
		public function get street():String
		{
			return _street;
		}
		
		private var _city:String;
		public function get city():String
		{
			return _city;
		}
	}
}