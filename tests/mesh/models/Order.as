package mesh.models
{
	import mesh.Entity;
	import mesh.adaptors.InMemoryAdaptor;
	
	[RemoteClass(alias="mesh.models.Order")]
	[ComposedOf(property="shippingAddress", type="mesh.models.Address", prefix="shippingAddress", mapping="street,city")]
	[BelongsTo(type="mesh.models.Customer", property="customer", key="customerId")]
	public dynamic class Order extends Entity
	{
		[ServiceAdaptor]
		public static var adaptor:InMemoryAdaptor;
		
		[Bindable] public var total:Number;
		
		public function Order()
		{
			super();
			Address;
			Customer;
		}
	}
}