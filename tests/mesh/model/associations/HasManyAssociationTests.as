package mesh.model.associations
{
	import mesh.Address;
	import mesh.Customer;
	import mesh.Order;
	import mesh.TestSource;
	import mesh.model.store.Store;
	
	import mx.collections.ArrayList;
	
	import org.flexunit.assertThat;
	import org.hamcrest.object.equalTo;

	public class HasManyAssociationTests
	{
		private var _store:Store;
		private var _customer:Customer;
		
		[Before]
		public function setup():void
		{
			_store = new Store(new TestSource());
			_customer = new Customer();
			_customer.orders = new ArrayList();
			_store.add(_customer);
		}
		
		[Test]
		public function testAddingEntityAddsEntityToStore():void
		{
			var order:Order = new Order();
			order.shippingAddress = new Address("2306 Zanker Rd", "San Jose");
			order.total = 10.00;
			_customer.orders.addItem(order);
			
			assertThat(order.store, equalTo(_customer.store));
		}
		
		[Test]
		public function testAddingEntityPopulatesInverseAssociation():void
		{
			var order:Order = new Order();
			order.shippingAddress = new Address("2306 Zanker Rd", "San Jose");
			order.total = 10.00;
			_customer.orders.addItem(order);
			
			assertThat(order.customer, equalTo(_customer));
		}
		
		[Test]
		public function testAssigningAssociationAssociatesEntities():void
		{
			var order:Order = new Order();
			order.shippingAddress = new Address("2306 Zanker Rd", "San Jose");
			order.total = 10.00;
			_customer.orders = new ArrayList([order]);
			
			assertThat(order.customer, equalTo(_customer));
		}
		
		[Test]
		public function testDestroyedEntityIsRemovedFromAssociation():void
		{
			var order:Order = new Order();
			order.shippingAddress = new Address("2306 Zanker Rd", "San Jose");
			order.total = 10.00;
			_customer.orders = new ArrayList([order]);
			_store.commit();
			assertThat("Precondition failed", order.status.isSynced, equalTo(true));
			
			order.destroy();
			assertThat(_customer.orders.length, equalTo(0));
		}
		
		[Test]
		public function testRevivedEntityIsAddedBackToAssociation():void
		{
			var order:Order = new Order();
			order.shippingAddress = new Address("2306 Zanker Rd", "San Jose");
			order.total = 10.00;
			_customer.orders = new ArrayList([order]);
			_store.commit();
			assertThat("Precondition failed", order.status.isSynced, equalTo(true));
			
			order.destroy();
			order.revive();
			assertThat(_customer.orders.length, equalTo(1));
		}
		
		[Test]
		public function testEntityIsNotAddedMultipleTimesOnStatusChange():void
		{
			var order:Order = new Order();
			order.shippingAddress = new Address("2306 Zanker Rd", "San Jose");
			order.total = 10.00;
			_customer.orders = new ArrayList([order]);
			_store.commit();
			assertThat("Precondition failed", order.status.isSynced, equalTo(true));
			
			order.synced();
			assertThat(_customer.orders.length, equalTo(1));
		}
		
		[Test]
		public function testDestroyedEntityIsRevivedWhenAddedToAssociation():void
		{
			var order:Order = new Order();
			order.shippingAddress = new Address("2306 Zanker Rd", "San Jose");
			order.total = 10.00;
			_customer.orders = new ArrayList([order]);
			_store.commit();
			assertThat("Precondition failed", order.status.isSynced, equalTo(true));
			
			order.destroy();
			_customer.orders.addItem(order);
			assertThat(order.status.isPersisted, equalTo(true));
			assertThat(_customer.orders.length, equalTo(1));
		}
	}
}