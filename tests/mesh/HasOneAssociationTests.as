package mesh
{
	import mesh.models.Account;
	import mesh.models.Customer;
	
	import org.flexunit.assertThat;
	import org.hamcrest.object.equalTo;

	public class HasOneAssociationTests
	{
		private var _customer:Customer;
		
		[Before]
		public function setup():void
		{
			_customer = new Customer();
		}
		
		[Test]
		public function testAssociatingDestroyedEntityIsDirty():void
		{
			var account:Account = new Account();
			account.id = 3;
			account.number = "000-001";
			account.callback("afterDestroy");
			
			_customer.account = account;
			assertThat(_customer.account.isDirty, equalTo(true));
		}
		
		[Test]
		public function testDestroyedEntityIsNewWhenAssociating():void
		{
			var account:Account = new Account();
			account.id = 3;
			account.number = "000-001";
			account.callback("afterDestroy");
			
			_customer.account = account;
			assertThat(account.isNew, equalTo(true));
			assertThat(account.isDirty, equalTo(true));
		}
		
		[Test]
		public function testBelongsToIsPopulated():void
		{
			var account:Account = new Account();
			_customer.account = account;
			
			assertThat(account.customer.target, equalTo(_customer));
		}
	}
}