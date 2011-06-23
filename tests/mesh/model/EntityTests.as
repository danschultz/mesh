package mesh.model
{
	import mesh.Customer;
	import mesh.Mesh;
	import mesh.Name;
	import mesh.services.Request;
	
	import org.flexunit.assertThat;
	import org.hamcrest.object.equalTo;

	public class EntityTests
	{
		private var _customer:Customer;
		
		[Before]
		public function setup():void
		{
			_customer = new Customer();
			_customer.name = new Name("Jimmy", "Page");
			_customer.age = 67;
			_customer.save().execute();
		}
		
		[Test]
		public function testReload():void
		{
			var customer:Request = Mesh.service(Customer).find(_customer.id).execute();
			customer.age = 68;
			customer.reload().execute();
			
			assertThat(customer.age, equalTo(_customer.age));
			assertThat(customer.isDirty, equalTo(false));
		}
	}
}