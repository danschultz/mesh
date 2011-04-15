package mesh.model
{
	import flash.utils.flash_proxy;
	
	
	import org.flexunit.assertThat;
	import org.hamcrest.object.equalTo;
	import mesh.Customer;
	import mesh.Order;

	public class HasManyAssociationTests
	{
		[Test]
		public function testPopulateInverseAssociation():void
		{
			var order:Order = new Order();
			var customer:Customer = new Customer();
			customer.orders.addItem(order);
			
			assertThat(order.customer.flash_proxy::object, equalTo(customer));
		}
	}
}