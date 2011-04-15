package mesh
{
	import mesh.models.Address;
	import mesh.models.Customer;
	import mesh.models.Name;
	
	import org.flexunit.assertThat;
	import org.hamcrest.collection.arrayWithSize;
	import org.hamcrest.collection.emptyArray;
	import org.hamcrest.object.equalTo;

	public class ValidationTests
	{
		[Test]
		public function testValidatePasses():void
		{
			var customer:Customer = new Customer();
			customer.name = new Name("John", "Doe");
			customer.address = new Address("1 Infinite Loop", "Cupertino");
			customer.age = 10;
			
			assertThat(customer.isValid(), equalTo(true));
			assertThat(customer.isInvalid(), equalTo(false));
			assertThat(customer.errors.toArray(), emptyArray());
		}
		
		[Test]
		public function testValidateFails():void
		{
			var customer:Customer = new Customer();
			customer.name = null;
			customer.address = null;
			customer.age = 0;
			
			assertThat(customer.isValid(), equalTo(false));
			assertThat(customer.isInvalid(), equalTo(true));
			assertThat(customer.errors.toArray(), arrayWithSize(3));
		}
	}
}