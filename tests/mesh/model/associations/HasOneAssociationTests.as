package mesh.model.associations
{
	import mesh.Account;
	import mesh.Customer;
	import mesh.model.source.Source;
	import mesh.model.store.Store;
	
	import org.flexunit.assertThat;
	import org.hamcrest.object.equalTo;

	public class HasOneAssociationTests
	{
		private var _store:Store;
		private var _customer:Customer;
		
		[Before]
		public function setup():void
		{
			_store = new Store(new Source());
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
	}
}