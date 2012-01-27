package mesh
{
	import mesh.model.Record;
	
	public class Order extends Record
	{
		[Bindable] public var customer:Customer;
		[Bindable] public var customerId:int;
		
		public function Order(values:Object=null)
		{
			super(values);
		}
	}
}