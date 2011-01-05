package mesh.models
{
	import mesh.adaptors.InMemoryAdaptor;
	
	[Validate(properties="addressStreet,addressCity", validator="mesh.validators.LengthValidator", minimum="1")]
	[ComposedOf(property="address", type="mesh.models.Address", prefix="address", mapping="street,city")]
	
	[HasMany(type="mesh.models.Order", property="orders")]
	[HasMany(type="mesh.models.Car")]
	
	public dynamic class Customer extends Person
	{
		[ServiceAdaptor]
		public static var adaptor:InMemoryAdaptor = new InMemoryAdaptor(Customer);
		
		public function Customer()
		{
			super();
			
			Order;
			Car;
			Account;
		}
		
		[HasOne(type="mesh.models.Account")]
		public function get account():*
		{
			return association("account");
		}
		public function set account(value:*):void
		{
			association("account").target = value;
		}
	}
}