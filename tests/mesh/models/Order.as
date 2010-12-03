package mesh.models
{
	import mesh.Entity;
	
	[ComposedOf(property="shippingAddress", type="mesh.models.Address", prefix="shippingAddress", mapping="street,city")]
	public dynamic class Order extends Entity
	{
		public function Order()
		{
			
		}
	}
}