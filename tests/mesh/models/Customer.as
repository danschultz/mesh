package mesh.models
{
	import mesh.Entity;
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
		}
		
		[HasOne(type="mesh.models.Car")]
		public function get primaryCar():*
		{
			return association("primaryCar");
		}
		public function set primaryCar(value:*):void
		{
			association("primaryCar").target = value;
		}
	}
}