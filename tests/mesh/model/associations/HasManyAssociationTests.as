package mesh.model.associations
{
	import mesh.Address;
	import mesh.Customer;
	import mesh.Order;
	import mesh.model.source.Source;
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
			_store = new Store(new Source());
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
	}
}