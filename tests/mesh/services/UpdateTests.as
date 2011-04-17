package mesh.services
{
	import mesh.Customer;
	import mesh.Mesh;
	import mesh.Name;
	
	import org.flexunit.assertThat;
	import org.hamcrest.object.equalTo;

	public class UpdateTests
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
		public function testUpdate():void
		{
			_customer.age++;
			_customer.save().execute();
			
			var query:Request = Mesh.services.serviceFor(Customer).find(_customer.id).execute();
			assertThat(query.age, equalTo(_customer.age));
		}
	}
}