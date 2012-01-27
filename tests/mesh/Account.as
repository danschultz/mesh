package mesh
{
	import mesh.model.Record;
	
	public class Account extends Record
	{
		[Bindable] public var customer:Customer;
		[Bindable] public var customerId:int;
		
		public function Account(values:Object=null)
		{
			super(values);
		}
	}
}