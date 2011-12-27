package mesh.model.associations
{
	import mesh.Address;
	import mesh.Customer;
	import mesh.Order;
	
	import mx.collections.ArrayList;
	
	import org.flexunit.assertThat;
	import org.hamcrest.object.equalTo;
	
	[Ignore]
	public class HasManyAssociationTests
	{
		//private var _store:Store;
		private var _customer:Customer;
		
		[Before]
		public function setup():void
		{
			//_store = new Store(new TestSource());
			//_customer = _store.create(Customer, {});
			//_customer.orders = new ArrayList();
		}
		
		[Test]
		public function testAddingEntityAddsEntityToStore():void
		{
			var order:Order = new Order();
			order.shippingAddress = new Address("2306 Zanker Rd", "San Jose");
			order.total = 10.00;
			_customer.orders.addItem(order);
			
			//assertThat(order.store, equalTo(_customer.store));
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
		public function testEntityIsNotAddedMultipleTimesOnStatusChange():void
		{
			var order:Order = new Order();
			order.shippingAddress = new Address("2306 Zanker Rd", "San Jose");
			order.total = 10.00;
			_customer.orders = new ArrayList([order]);
			//_store.commit();
			//assertThat("Precondition failed", order.status.isSynced, equalTo(true));
			
			//order.synced();
			assertThat(_customer.orders.length, equalTo(1));
		}
	}
}