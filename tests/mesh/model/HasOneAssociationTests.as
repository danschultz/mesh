package mesh.model
{
	import flash.utils.flash_proxy;
	
	import mesh.Account;
	import mesh.Customer;
	import mesh.Mesh;
	import mesh.services.Request;
	
	import org.flexunit.assertThat;
	import org.hamcrest.object.equalTo;
	
	use namespace flash_proxy;

	public class HasOneAssociationTests
	{
		private var _customer:Customer;
		
		[Before]
		public function setup():void
		{
			_customer = new Customer();
			_customer.save().execute();
		}
		
		[Test]
		public function testAssociatingDestroyedEntityIsDirty():void
		{
			var account:Account = new Account();
			account.id = 3;
			account.number = "000-001";
			account.callback("afterDestroy");
			
			_customer.account.object = account;
			assertThat(_customer.account.isDirty, equalTo(true));
		}
		
		[Test]
		public function testDestroyedEntityIsNewWhenAssociating():void
		{
			var account:Account = new Account();
			account.id = 3;
			account.number = "000-001";
			account.callback("afterDestroy");
			
			_customer.account.object = account;
			assertThat(account.isNew, equalTo(true));
			assertThat(account.isDirty, equalTo(true));
		}
		
		[Test]
		public function testForeignKeyIsPopulatedOnAssignment():void
		{
			var account:Account = new Account();
			account.id = 3;
			account.number = "000-001";
			
			_customer.account.object = account;
			assertThat(_customer.accountId, equalTo(account.id));
		}
		
		[Test]
		public function testSavePersistsObject():void
		{
			var account:Account = new Account();
			account.number = "000-001";
			
			_customer.account.object = account;
			_customer.account.save().execute();
			
			assertThat(account.isPersisted, equalTo(true));
		}
		
		[Test]
		public function testSavePopulatesForeignKeyOnOwner():void
		{
			var account:Account = new Account();
			account.number = "000-001";
			
			_customer.account.object = account;
			_customer.account.save().execute();
			
			assertThat(_customer.accountId, equalTo(account.id));
		}
		
		[Test]
		public function testLoad():void
		{
			var account:Account = new Account();
			account.number = "000-001";
			
			_customer.account.object = account;
			_customer.account.save().execute();
			_customer.save().execute();
			
			var customer:Request = Mesh.services.serviceFor(Customer).find(_customer.id).execute();
			customer.account.load().execute();
			assertThat(customer.account.id, equalTo(account.id));
		}
	}
}