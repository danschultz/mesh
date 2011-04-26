package mesh.model
{
	import flash.utils.flash_proxy;
	
	import mesh.Customer;
	import mesh.Mesh;
	import mesh.Order;
	import mesh.services.Request;
	
	import org.flexunit.assertThat;
	import org.hamcrest.collection.everyItem;
	import org.hamcrest.object.equalTo;
	import org.hamcrest.object.hasPropertyWithValue;

	public class HasManyAssociationTests
	{
		private var _customer:Customer;
		
		[Before]
		public function setup():void
		{
			_customer = new Customer();
			_customer.save().execute();
		}
		
		[Test]
		public function testPopulateInverseAssociation():void
		{
			var order:Order = new Order();
			var customer:Customer = new Customer();
			customer.orders.addItem(order);
			
			assertThat(order.customer.flash_proxy::object, equalTo(customer));
		}
		
		[Test]
		public function testSave():void
		{
			var order1:Order = new Order();
			var order2:Order = new Order();
			
			_customer.orders.add(order1);
			_customer.orders.add(order2);
			_customer.orders.save().execute();
			
			assertThat([order1, order2], everyItem(hasPropertyWithValue("isPersisted", true)));
		}
		
		[Test]
		public function testSaveRemoved():void
		{
			var order:Order = new Order();
			
			_customer.orders.add(order);
			_customer.orders.save().execute();
			
			_customer.orders.remove(order);
			_customer.orders.save().execute();
			
			assertThat(order.isDestroyed, equalTo(true));
		}
		
		[Test]
		public function testAutoSave():void
		{
			var order1:Order = new Order();
			var order2:Order = new Order();
			
			_customer.orders.add(order1);
			_customer.orders.add(order2);
			_customer.save().execute();
			
			assertThat([order1, order2], everyItem(hasPropertyWithValue("isPersisted", true)));
		}
		
		[Test]
		public function testAutoSaveRemoved():void
		{
			var order:Order = new Order();
			
			_customer.orders.add(order);
			_customer.orders.save().execute();
			
			_customer.orders.remove(order);
			_customer.save().execute();
			
			assertThat(order.isDestroyed, equalTo(true));
		}
		
		[Test]
		public function testLoad():void
		{
			var order1:Order = new Order();
			var order2:Order = new Order();
			_customer.orders.add(order1);
			_customer.orders.add(order2);
			_customer.orders.save().execute();
			
			var customer:Request = Mesh.service(Customer).find(_customer.id).execute();
			var orders:Request = customer.orders.load().execute();
			assertThat(customer.orders.length, equalTo(_customer.orders.length));
			assertThat(customer.orders.isLoaded, equalTo(true));
		}
	}
}