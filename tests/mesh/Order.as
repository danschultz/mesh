package mesh
{
	import mesh.core.object.copy;
	
	[RemoteClass(alias="mesh.Order")]
	
	public class Order extends TestEntity
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
		
		override public function toObject():Object
		{
			var object:Object = super.toObject();
			copy(this, object, {includes:["customerId", "shippingAddress", "total"]});
			return object;
		}
	}
}