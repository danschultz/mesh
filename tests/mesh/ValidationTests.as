package mesh
{
	import org.flexunit.assertThat;
	import org.hamcrest.collection.array;
	import org.hamcrest.collection.arrayWithSize;
	import org.hamcrest.collection.emptyArray;
	import org.hamcrest.collection.hasItems;
	import org.hamcrest.object.equalTo;
	import org.hamcrest.object.hasProperties;
	import org.hamcrest.object.hasProperty;

	public class ValidationTests
	{
		[Test]
		public function testValidatePasses():void
		{
			var mockEntity:Customer = new Customer();
			mockEntity.firstName = "John Doe";
			mockEntity.streetAddress = "2306 Zanker Rd";
			mockEntity.cityAddress = "San Jose";
			
			assertThat(mockEntity.validate(), emptyArray());
			assertThat(mockEntity.isValid(), equalTo(true));
			assertThat(mockEntity.isInvalid(), equalTo(false));
		}
		
		[Test]
		public function testValidateFails():void
		{
			var mockEntity:Customer = new Customer();
			mockEntity.firstName = "";
			mockEntity.streetAddress = "";
			mockEntity.cityAddress = "";
			
			assertThat(mockEntity.validate(), arrayWithSize(2));
			assertThat(mockEntity.isValid(), equalTo(false));
			assertThat(mockEntity.isInvalid(), equalTo(true));
		}
		
		[Test]
		public function testEntityParsesValidationMetadata():void
		{
			var validations:Array = new Customer().validations;
			assertThat(validations, hasItems(hasProperty("options", hasProperty("minimum")), 
											 hasProperty("options", hasProperty("maximum")),
											 hasProperty("options", hasProperty("property", equalTo("firstName"))),
											 hasProperty("options", hasProperty("properties", array(equalTo("streetAddress"), equalTo("cityAddress"))))));
		}
	}
}