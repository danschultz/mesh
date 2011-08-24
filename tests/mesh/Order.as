package mesh
{
	import mesh.model.Entity;
	
	[RemoteClass(alias="mesh.Order")]
	
	public class Order extends Entity
	{
		public var customerId:int;
		[Bindable] public var customer:Customer;
		[Bindable] public var shippingAddress:Address;
		[Bindable] public var total:Number;
		
		public function Order(properties:Object = null)
		{
			super(properties);
			hasOne("customer");
		}
	}
}