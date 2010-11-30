package mesh
{
	[Validate(properties="streetAddress,cityAddress", validator="validations.LengthValidator", minimum="1")]
	
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
		
		private var _firstName:String;
		[Validate(validator="validations.LengthValidator", maximum="50")]
		public function get firstName():String
		{
			return _firstName;
		}
		public function set firstName(value:String):void
		{
			_firstName = value;
		}
		
		public function get validations():Array
		{
			return validators();
		}
	}
}