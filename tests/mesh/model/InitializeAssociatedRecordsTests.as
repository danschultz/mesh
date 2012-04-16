package mesh.model
{
	import mesh.Customer;
	import mesh.Order;
	import mesh.model.source.FixtureDataSource;
	import mesh.model.source.MultiDataSource;
	import mesh.model.store.Store;
	
	import org.flexunit.assertThat;
	import org.hamcrest.object.notNullValue;

	public class InitializeAssociatedRecordsTests
	{
		private var _store:Store;
		
		[Before]
		public function setup():void
		{
			var customers:FixtureDataSource = new FixtureDataSource(Customer);
			customers.add({id:1, firstName:"Jimmy", lastName:"Page", accountId:1});
			
			var dataSource:MultiDataSource = new MultiDataSource();
			dataSource.map(Customer, customers);
			dataSource.map(Order, new FixtureDataSource(Order));
			
			_store = new Store(dataSource);
		}
		
		[Test]
		public function testInitializeHasOneAssociation():void
		{
			var customer:Customer = _store.query(Customer).find(1).load();
			assertThat(customer.account, notNullValue());
		}
		
		[Test]
		public function testInitializeHasManyAssociation():void
		{
			var customer:Customer = _store.query(Customer).find(1).load();
			assertThat(customer.orders, notNullValue());
		}
	}
}