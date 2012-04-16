package mesh.model
{
	import mesh.Name;
	import mesh.Person;
	
	import org.flexunit.assertThat;
	import org.hamcrest.collection.arrayWithSize;
	import org.hamcrest.collection.emptyArray;
	import org.hamcrest.object.equalTo;

	public class ValidationTests
	{
		[Test]
		public function testValidatePasses():void
		{
			var customer:Person = new Person();
			customer.name = new Name("John", "Doe");
			customer.age = 10;
			
			assertThat(customer.isValid(), equalTo(true));
			assertThat(customer.isInvalid(), equalTo(false));
			assertThat(customer.errors.toArray(), emptyArray());
		}
		
		[Test]
		public function testValidateFails():void
		{
			var customer:Person = new Person();
			customer.name = null;
			customer.age = 0;
			
			assertThat(customer.isValid(), equalTo(false));
			assertThat(customer.isInvalid(), equalTo(true));
			assertThat(customer.errors.toArray(), arrayWithSize(2));
		}
	}
}