package mesh
{
	public class Customer extends Person
	{
		[Bindable] public var account:Account;
		[Bindable] public var accountId:int;
		
		public function Customer(properties:Object=null)
		{
			super(properties);
			
			hasOne("account");
		}
	}
}