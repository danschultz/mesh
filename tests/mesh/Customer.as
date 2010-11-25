package mesh
{
	[Validate(property="street", validator="Length", lessThan="10")]
	
	[ComposedOf(property="address", type="mesh.Address", prefix="address", mapping="street,city")]
	public dynamic class Customer extends Entity
	{
		public function Customer()
		{
			super();
		}
		
		private var _address2:Address;
		[ComposedOf(mapping="streetAddress:street,cityAddress:city")]
		public function get address2():Address
		{
			return _address2;
		}
		public function set address2(value:Address):void
		{
			_address2 = value;
		}
	}
}