package mesh.model.associations
{
	import mesh.Account;
	import mesh.Customer;
	import mesh.TestSource;
	import mesh.model.store.Store;
	
	import org.flexunit.assertThat;
	import org.hamcrest.object.equalTo;
	import org.hamcrest.object.nullValue;

	public class HasOneAssociationTests
	{
		private var _store:Store;
		private var _customer:Customer;
		
		[Before]
		public function setup():void
		{
			_store = new Store(new TestSource());
			_customer = new Customer();
			_store.add(_customer);
		}
		
		[Test]
		public function testAddingEntityAddsEntityToStore():void
		{
			var account:Account = new Account();
			account.number = "001-001";
			_customer.account = account;
			
			assertThat(account.store, equalTo(_customer.store));
		}
		
		[Test]
		public function testAddingEntityPopulatesInverseAssociation():void
		{
			var account:Account = new Account();
			account.number = "001-001";
			_customer.account = account;
			
			assertThat(account.customer, equalTo(_customer));
		}
		
		[Test]
		public function testDestroyedEntityIsRemovedFromAssociation():void
		{
			var account:Account = new Account();
			account.number = "001-001";
			_customer.account = account;
			_store.commit();
			assertThat("Precondition failed", account.status.isSynced, equalTo(true));
			
			account.destroy();
			assertThat(_customer.account, nullValue());
		}
		
		[Test]
		public function testRevivedEntityIsAddedBackToAssociation():void
		{
			var account:Account = new Account();
			account.number = "001-001";
			_customer.account = account;
			_store.commit();
			assertThat("Precondition failed", account.status.isSynced, equalTo(true));
			
			account.destroy();
			account.revive();
			assertThat(_customer.account, equalTo(account));
		}
		
		[Test]
		public function testEntityIsRevivedWhenAddedBackToAssociation():void
		{
			var account:Account = new Account();
			account.number = "001-001";
			_customer.account = account;
			_store.commit();
			assertThat("Precondition failed", account.status.isSynced, equalTo(true));
			
			account.destroy();
			_customer.account = account;
			assertThat(account.status.isPersisted, equalTo(true));
		}
	}
}