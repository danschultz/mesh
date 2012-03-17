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
	import org.hamcrest.collection.emptyArray;
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
			_customers.add({
				id: 1, 
				firstName: "Jimmy", 
				lastName: "Page", 
				accountId: 1,
				orders: [{id:1, customerId:1}, {id:2, customerId:1}, {id:3, customerId:1}]
			});
			
			var dataSources:MultiDataSource = new MultiDataSource();
			dataSources.map(Customer, _customers);
			
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
			var order:Order = _store.materialize( new Data(Order, {id:2}) );
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
		public function testRemoveRecord():void
		{
			var customer:Customer = _store.query(Customer).find(1).load();
			customer.orders.load();
			
			var order:Order = customer.orders.removeItemAt(0) as Order;
			assertThat(customer.state.isSynced, equalTo(false));
			assertThat(customer.orders.removed.length, equalTo(1));
			assertThat(customer.orders.length, equalTo(2));
			assertThat(order.customer, nullValue());
		}
		
		[Test]
		public function testRemoveAllRecords():void
		{
			var customer:Customer = _store.query(Customer).find(1).load();
			customer.orders.load();
			
			customer.orders.removeAll();
			assertThat(customer.state.isSynced, equalTo(false));
			assertThat(customer.orders.removed.length, equalTo(3));
			assertThat(customer.orders.length, equalTo(0));
		}
		
		[Test]
		public function testSaveUpdatedRecords():void
		{
			var customer:Customer = _store.query(Customer).find(1).load();
			customer.orders.load();
			
			var order:Order = customer.orders.at(0);
			order.total = 10;
			
			customer.orders.persist();
			assertThat(order.state.isSynced, equalTo(true));
		}
		
		[Test]
		public function testSaveDestroyedRecords():void
		{
			var customer:Customer = _store.query(Customer).find(1).load();
			customer.orders.load();
			
			var order:Order = customer.orders.at(1);
			order.destroy();
			
			customer.orders.persist();
			
			assertThat(customer.orders.toArray(), arrayWithSize(2));
			assertThat(order.state.isRemote, equalTo(false));
			assertThat(order.state.isSynced, equalTo(true));
		}
		
		[Test]
		public function testSaveRemovedRecords():void
		{
			var customer:Customer = _store.query(Customer).find(1).load();
			customer.orders.load();
			
			var order:Order = customer.orders.removeItemAt(1) as Order;
			
			customer.orders.persist();
			
			assertThat(customer.orders.toArray(), arrayWithSize(2));
			assertThat(order.state.isRemote, equalTo(true));
			assertThat(order.state.isSynced, equalTo(true));
			assertThat(customer.orders.removed, emptyArray());
		}
	}
}