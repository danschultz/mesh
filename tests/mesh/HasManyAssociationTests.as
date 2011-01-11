package mesh
{
	import mesh.models.Customer;
	import mesh.models.Order;
	
	import org.flexunit.assertThat;
	import org.hamcrest.object.equalTo;

	public class HasManyAssociationTests
	{
		[Test]
		public function testBelongsToIsPopulated():void
		{
			var order:Order = new Order();
			var customer:Customer = new Customer();
			customer.orders.addItem(order);
			
			assertThat(order.customer.target, equalTo(customer));
		}
	}
}