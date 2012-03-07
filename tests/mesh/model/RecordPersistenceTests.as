package mesh.model
{
	import mesh.Customer;
	import mesh.Name;
	import mesh.Order;
	import mesh.model.source.FixtureDataSource;
	import mesh.model.source.MultiDataSource;
	import mesh.model.store.Store;
	
	import org.flexunit.assertThat;
	import org.hamcrest.object.equalTo;

	public class RecordPersistenceTests
	{
		private var _store:Store;
		private var _customers:FixtureDataSource;
		private var _orders:FixtureDataSource;
		
		[Before]
		public function setup():void
		{
			_customers = new FixtureDataSource(Customer);
			_customers.add({id:1, firstName:"Jimmy", lastName:"Page", accountId:1});
			
			_orders = new FixtureDataSource(Order);
			_orders.add({id:1, customerId:1});
			_orders.add({id:2, customerId:1});
			_orders.add({id:3, customerId:1});
			
			var dataSources:MultiDataSource = new MultiDataSource();
			dataSources.map(Customer, _customers);
			dataSources.map(Order, _orders);
			
			_store = new Store(dataSources);
		}
		
		[Test]
		public function testCreate():void
		{
			var customer:Customer = _store.create(Customer);
			customer.persist();
			
			assertThat(ID.isPopulated(customer), equalTo(true));
			assertThat(customer.state.isRemote, equalTo(true));
			assertThat(customer.state.isSynced, equalTo(true));
		}
		
		[Test]
		public function testUpdate():void
		{
			var customer:Customer = _store.query(Customer).find(1).load();
			customer.name = new Name("Steve", "Jobs");
			customer.persist();
			
			assertThat(customer.state.isRemote, equalTo(true));
			assertThat(customer.state.isSynced, equalTo(true));
		}
	}
}