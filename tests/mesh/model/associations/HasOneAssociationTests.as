package mesh.model.associations
{
	import mesh.Account;
	import mesh.Customer;
	import mesh.Order;
	import mesh.mesh_internal;
	import mesh.model.source.FixtureDataSource;
	import mesh.model.source.MultiDataSource;
	import mesh.model.store.Data;
	import mesh.model.store.Store;
	
	import org.flexunit.assertThat;
	import org.hamcrest.object.equalTo;
	import org.hamcrest.object.notNullValue;
	
	use namespace mesh_internal;

	public class HasOneAssociationTests
	{
		private var _store:Store;
		private var _accounts:FixtureDataSource;
		private var _customers:FixtureDataSource;
		
		[Before]
		public function setup():void
		{
			_customers = new FixtureDataSource(Customer);
			_customers.add({id:1, firstName:"Jimmy", lastName:"Page", accountId:1});
			
			_accounts = new FixtureDataSource(Account);
			_accounts.add({id:1, customerId:1});
			
			var dataSources:MultiDataSource = new MultiDataSource();
			dataSources.map(Customer, _customers);
			dataSources.map(Account, _accounts);
			dataSources.map(Order, new FixtureDataSource(Order));
			
			_store = new Store(dataSources);
		}
		
		[Test]
		/**
		 * Test loading the has-one association.
		 */
		public function testLoad():void
		{
			var customer:Customer = _store.query(Customer).find(1).load();
			customer.account.load();
			assertThat(customer.account.customer, equalTo(customer));
		}
		
		[Test]
		/**
		 * Test that the associated record changes, when the foreign key changes.
		 */
		public function testResetAssociationOnForeignKeyChange():void
		{
			var customer:Customer = _store.query(Customer).find(1).load();
			customer.accountId = 2;
			assertThat(customer.account.id, equalTo(customer.accountId));
		}
		
		[Test]
		/**
		 * Test that the foreign key is updated when the association is set.
		 */
		public function testPopulateForeignKeyWhenAssociationSet():void
		{
			var customer:Customer = _store.query(Customer).find(1).load();
			var account:Account = _store.materialize( new Data({id:2}, Account) );
			customer.account = account;
			assertThat(customer.accountId, equalTo(customer.account.id));
		}
		
		[Test]
		public function testAssociatedRecordsAreInsertedIntoTheStore():void
		{
			var customer:Customer = _store.query(Customer).find(1).load();
			var account:Account = new Account();
			customer.account = account;
			assertThat(account.store, notNullValue());
		}
	}
}