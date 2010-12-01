package mesh
{
	import mesh.models.Address;
	import mesh.models.Customer;
	import mesh.models.Name;
	
	import org.flexunit.assertThat;
	import org.hamcrest.object.equalTo;
	import org.hamcrest.object.notNullValue;

	public class EntityPropertyWasTests
	{
		private var _customer:Customer;
		
		[Before]
		public function setup():void
		{
			_customer = new Customer();
			_customer.fullName = new Name("John", "Doe");
			_customer.address = new Address("2306 Zanker Rd", "San Jose");
			_customer.age = 21;
			_customer.saved();
		}
		
		[Test]
		public function testPropertyWasReturnsUndefinedAfterSave():void
		{
			_customer.firstName = "Jane";
			_customer.saved();
			assertThat(_customer.firstNameWas === undefined, equalTo(true));
		}
		
		[Test]
		public function testPropertyWasValueWithDefinedProperty():void
		{
			var oldFirstName:String = _customer.firstName;
			_customer.firstName = "Jane";
			assertThat(oldFirstName, notNullValue());
			assertThat(_customer.firstNameWas, equalTo(oldFirstName));
		}
		
		[Test]
		public function testPropertyWasValueWithDefinedBindableProperty():void
		{
			var oldAge:Number = _customer.age;
			_customer.age++;
			assertThat(oldAge, notNullValue());
			assertThat(_customer.ageWas, equalTo(oldAge));
		}
		
		[Test]
		public function testPropertyWasValueWithDynamicProperty():void
		{
			var oldAddressStreet:String = _customer.addressStreet;
			_customer.addressStreet = "1 Infinite Loop";
			assertThat(oldAddressStreet, notNullValue());
			assertThat(_customer.addressStreetWas, equalTo(oldAddressStreet));
		}
	}
}