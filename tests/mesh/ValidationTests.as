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
			customer.fullName = new Name("John", "Doe");
			customer.address = new Address("1 Infinite Loop", "Cupertino");
			customer.age = 10;
			
			assertThat(customer.validate(), emptyArray());
			assertThat(customer.errors.toArray(), emptyArray());
			assertThat(customer.isValid(), equalTo(true));
			assertThat(customer.isInvalid(), equalTo(false));
		}
		
		[Test]
		public function testValidateFails():void
		{
			var customer:Customer = new Customer();
			customer.fullName = new Name("", "");
			customer.address = new Address("", "");
			customer.age = 0;
			
			assertThat(customer.validate(), arrayWithSize(9));
			assertThat(customer.errors.toArray(), arrayWithSize(9));
			assertThat(customer.isValid(), equalTo(false));
			assertThat(customer.isInvalid(), equalTo(true));
		}
	}
}