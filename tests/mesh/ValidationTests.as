package mesh
{
	import mesh.models.Address;
	import mesh.models.Customer;
	import mesh.models.Name;
	
	import org.flexunit.assertThat;
	import org.hamcrest.collection.array;
	import org.hamcrest.collection.arrayWithSize;
	import org.hamcrest.collection.emptyArray;
	import org.hamcrest.collection.hasItems;
	import org.hamcrest.core.allOf;
	import org.hamcrest.object.equalTo;
	import org.hamcrest.object.hasProperty;

	public class ValidationTests
	{
		[Test]
		public function testValidatePasses():void
		{
			var mockEntity:Customer = new Customer();
			mockEntity.fullName = new Name("John", "Doe");
			mockEntity.address = new Address("1 Infinite Loop", "Cupertino");
			mockEntity.age = 10;
			
			assertThat(mockEntity.validate(), emptyArray());
			assertThat(mockEntity.isValid(), equalTo(true));
			assertThat(mockEntity.isInvalid(), equalTo(false));
		}
		
		[Test]
		public function testValidateFails():void
		{
			var mockEntity:Customer = new Customer();
			mockEntity.fullName = new Name("", "");
			mockEntity.address = new Address("", "");
			mockEntity.age = 0;
			
			assertThat(mockEntity.validate(), arrayWithSize(5));
			assertThat(mockEntity.isValid(), equalTo(false));
			assertThat(mockEntity.isInvalid(), equalTo(true));
		}
		
		[Test]
		public function testEntityParsesValidationMetadata():void
		{
			var validations:Array = new Customer().validations;
			assertThat(validations, hasItems(hasProperty("options", allOf(hasProperty("lessThanOrEqualTo"), hasProperty("greaterThanOrEqualTo"))), 
											 hasProperty("options", hasProperty("minimum")),
											 hasProperty("options", hasProperty("property", equalTo("age"))),
											 hasProperty("options", hasProperty("properties", array(equalTo("firstName"), equalTo("lastName"))))));
		}
	}
}