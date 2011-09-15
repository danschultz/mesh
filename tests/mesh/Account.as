package mesh
{
	import mesh.model.Entity;
	
	public class Account extends Entity
	{
		[Bindable] public var customerId:int;
		[Bindable] public var customer:Customer;
		[Bindable] public var number:String;
		
		public function Account(properties:Object = null)
		{
			super(properties);
			hasOne("customer");
		}
	}
}