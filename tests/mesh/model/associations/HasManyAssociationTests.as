package mesh.model.associations
{
	import mesh.Customer;
	import mesh.Order;
	import mesh.mesh_internal;
	import mesh.model.source.FixtureDataSource;
	import mesh.model.source.MultiDataSource;
	import mesh.model.store.Data;
	import mesh.model.store.ResultsList;
	import mesh.model.store.Store;
	
	import org.flexunit.assertThat;
	import org.hamcrest.collection.arrayWithSize;
	import org.hamcrest.collection.everyItem;
	import org.hamcrest.core.allOf;
	import org.hamcrest.object.equalTo;
	import org.hamcrest.object.hasPropertyChain;
	import org.hamcrest.object.notNullValue;
	import org.hamcrest.object.nullValue;
	
	use namespace mesh_internal;
	
	public class HasManyAssociationTests
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
		public function testLoad():void
		{
			var customer:Customer = _store.query(Customer).find(1).load();
			customer.orders.load();
			assertThat(customer.orders.toArray(), allOf(arrayWithSize(3), everyItem(hasPropertyChain("state.isSynced", equalTo(true)))));
		}
		
		[Test]
		public function testAutoUpdateFromStore():void
		{
			var customer:Customer = _store.query(Customer).find(1).load();
			var orders:ResultsList = _store.query(Order).findAll().load();
			assertThat(customer.orders.toArray(), arrayWithSize(3));
		}
		
		[Test]
		/**
		 * Test that the foreign key is updated when the association is set.
		 */
		public function testPopulateForeignKeyWhenAssociationSet():void
		{
			var customer:Customer = _store.query(Customer).find(1).load();
			var order:Order = _store.materialize( new Data({id:2}, Order) );
			customer.orders.add(order);
			assertThat(order.customerId, equalTo(customer.id));
		}
		
		[Test]
		public function testAssociatedRecordsAreInsertedIntoTheStore():void
		{
			var customer:Customer = _store.query(Customer).find(1).load();
			var order:Order = new Order();
			customer.orders.add(order);
			assertThat(order.store, notNullValue());
		}
		
		[Test]
		public function testUnassociateRecord():void
		{
			var customer:Customer = _store.query(Customer).find(1).load();
			customer.orders.load();
			
			var order:Order = customer.orders.removeItemAt(0) as Order;
			assertThat(customer.orders.length, equalTo(2));
			assertThat(order.customer, nullValue());
		}
		
		[Test]
		public function testUnassociateAllRecords():void
		{
			var customer:Customer = _store.query(Customer).find(1).load();
			customer.orders.load();
			
			customer.orders.removeAll();
			assertThat(customer.orders.length, equalTo(0));
		}
	}
}