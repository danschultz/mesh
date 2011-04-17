package mesh.services
{
	import mesh.Customer;
	import mesh.Mesh;
	import mesh.Name;
	
	import org.flexunit.assertThat;
	import org.hamcrest.object.equalTo;
	import org.hamcrest.object.notNullValue;
	
	public class InsertTests
	{
		[Test]
		public function testInsert():void
		{
			var customer:Customer = new Customer();
			customer.name = new Name("Jimmy", "Page");
			customer.age = 67;
			customer.save().execute();
			
			var query:Request = Mesh.services.serviceFor(Customer).find(customer.id).execute();
			assertThat(customer.id, notNullValue());
			assertThat(query.id, equalTo(customer.id));
		}
	}
}