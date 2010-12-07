package mesh.models
{
	import mesh.Entity;
	
	[ComposedOf(property="shippingAddress", type="mesh.models.Address", prefix="shippingAddress", mapping="street,city")]
	[ServiceAdaptor(type="mesh.adaptors.InMemoryAdaptor")]
	public dynamic class Order extends Entity
	{
		[Bindable] public var total:Number;
		
		public function Order()
		{
			super();
		}
	}
}