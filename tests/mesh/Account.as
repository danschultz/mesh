package mesh
{
	import mesh.model.Record;
	
	[Bindable]
	public class Account extends Record
	{
		[HasOne]
		public var customer:Customer;
		public var customerId:int;
		
		public function Account(values:Object=null)
		{
			super(values);
		}
	}
}