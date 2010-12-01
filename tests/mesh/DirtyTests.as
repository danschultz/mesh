package mesh
{
	import mesh.models.Address;
	import mesh.models.Customer;
	import mesh.models.Name;
	
	import org.flexunit.assertThat;
	import org.hamcrest.object.equalTo;

	public class DirtyTests
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
		public function testDirtyUsesEqualsOnValueObjects():void
		{
			_customer.address = new Address("2306 Zanker Rd", "San Jose");
			assertThat(_customer.isDirty, equalTo(false));
		}
		
		[Test]
		public function testIsDirtyWhenPropertyChanges():void
		{
			_customer.address = new Address("1 Infinite Loop", "Cupertino");
			assertThat(_customer.isDirty, equalTo(true));
		}
		
		[Test]
		public function testIsNotDirtyWhenReverted():void
		{
			_customer.age = 10;
			_customer.firstName = "Jane";
			_customer.address = new Address("1 Infinite Loop", "Cupertino");
			
			_customer.revert();
			assertThat(_customer.isDirty, equalTo(false));
		}
	}
}