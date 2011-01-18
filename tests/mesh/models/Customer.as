package mesh.models
{
	import mesh.adaptors.InMemoryAdaptor;
	import mesh.validators.LengthValidator;
	import mesh.validators.PresenceValidator;
	
	[ComposedOf(property="address", type="mesh.models.Address", prefix="address", mapping="street,city")]
	
	[HasMany(type="mesh.models.Order", property="orders", autoSave="true")]
	[HasMany(type="mesh.models.Car")]
	
	public dynamic class Customer extends Person
	{
		[ServiceAdaptor]
		public static var adaptor:InMemoryAdaptor = new InMemoryAdaptor(Customer);
		
		public static var validate:Object = 
		{
			addressStreet: [{validator:PresenceValidator}, {validator:LengthValidator, minimum:2}],
			addressCity: [{validator:PresenceValidator}, {validator:LengthValidator, minimum:2}]
		};
		
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