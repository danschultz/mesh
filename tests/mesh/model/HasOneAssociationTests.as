package mesh.model
{
	import flash.utils.flash_proxy;
	
	
	import org.flexunit.assertThat;
	import org.hamcrest.object.equalTo;
	import mesh.Account;
	import mesh.Customer;

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
			
			_customer.account.flash_proxy::object = account;
			assertThat(_customer.account.isDirty, equalTo(true));
		}
		
		[Test]
		public function testDestroyedEntityIsNewWhenAssociating():void
		{
			var account:Account = new Account();
			account.id = 3;
			account.number = "000-001";
			account.callback("afterDestroy");
			
			_customer.account.flash_proxy::object = account;
			assertThat(account.isNew, equalTo(true));
			assertThat(account.isDirty, equalTo(true));
		}
		
		[Test]
		public function testForeignKeyIsPopulatedOnAssignment():void
		{
			var account:Account = new Account();
			account.id = 3;
			account.number = "000-001";
			
			_customer.account.flash_proxy::object = account;
			assertThat(_customer.accountId, equalTo(account.id));
		}
	}
}