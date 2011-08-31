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
			_customer.account = new Account({number:"001-001"});
			_store.add(_customer);
			_store.commit();
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
			_customer.account.destroy();
			assertThat(_customer.accountId, equalTo(0));
			assertThat(_customer.account, nullValue());
		}
		
		[Test]
		public function testRevivedEntityIsAddedBackToAssociation():void
		{
			var account:Account = _customer.account;
			account.destroy();
			account.revive();
			assertThat(_customer.accountId, equalTo(account.id));
			assertThat(_customer.account, equalTo(account));
		}
		
		[Test]
		public function testRevivedEntityIsNotAddedBackToAssociationWhenDestroyedRemotely():void
		{
			var account:Account = _customer.account;
			account.destroy();
			_store.commit();
			
			account.revive();
			assertThat(_customer.accountId, equalTo(0));
			assertThat(_customer.account, nullValue());
		}
		
		[Test]
		public function testEntityIsRevivedWhenAddedBackToAssociation():void
		{
			var account:Account = _customer.account;
			account.destroy();
			_customer.account = account;
			assertThat(account.status.isPersisted, equalTo(true));
		}
		
		[Test]
		public function testForeignKeyIsPopulatedOnSave():void
		{
			_customer.account = new Account({number:"001-002"});
			_store.commit();
			assertThat(_customer.accountId, equalTo(_customer.account.id));
		}
		
		[Test]
		public function testForeignKeyIsPopulatedOnAssociation():void
		{
			var account:Account = new Account({number:"001-002"});
			_store.add(account);
			_store.commit();
			
			_customer.account = account;
			assertThat(_customer.accountId, equalTo(_customer.account.id));
		}
		
		[Test]
		public function testForeignKeyIsNullifiedWhenAssociationIsNullified():void
		{
			_customer.account = new Account({number:"001-002"});
			_store.commit();
			
			_customer.account = null;
			assertThat(_customer.accountId, equalTo(0));
		}
	}
}