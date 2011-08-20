package mesh
{
	import mesh.core.object.copy;
	
	public class Order extends TestEntity
	{
		public var customerId:int;
		[Bindable] public var customer:Customer;
		[Bindable] public var shippingAddress:Address;
		[Bindable] public var total:Number;
		
		public function Order(properties:Object = null)
		{
			super(properties);
		}
		
		override public function toObject():Object
		{
			var object:Object = super.toObject();
			copy(this, object, {includes:["customerId", "shippingAddress", "total"]});
			return object;
		}
	}
}