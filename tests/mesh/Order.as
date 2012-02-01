package mesh
{
	import mesh.model.Record;
	
	[Bindable]
	public class Order extends Record
	{
		[HasOne]
		public var customer:Customer;
		public var customerId:int;
		
		public function Order(values:Object=null)
		{
			super(values);
		}
	}
}