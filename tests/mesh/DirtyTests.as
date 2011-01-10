package mesh
{
	import mesh.models.Account;
	import mesh.models.Address;
	import mesh.models.Customer;
	import mesh.models.Name;
	import mesh.models.Order;
	
	import org.flexunit.assertThat;
	import org.hamcrest.object.equalTo;
	import org.hamcrest.object.notNullValue;

	public class DirtyTests
	{
		private var _customer:Customer;
		
		[Before]
		public function setup():void
		{
			_customer = new Customer();
			_customer.id = 1;
			_customer.fullName = new Name("John", "Doe");
			_customer.address = new Address("2306 Zanker Rd", "San Jose");
			_customer.age = 21;
			
			var order:Order = new Order();
			order.id = 1;
			_customer.orders.addItem(order);
			
			var account:Account = new Account();
			account.id = 1;
			_customer.account = account;
			
			_customer.found();
		}
		
		[Test]
		public function testPropertyWasReturnsUndefinedAfterSave():void
		{
			_customer.firstName = "Jane";
			_customer.persisted();
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
		
		[Test]
		public function testIsNotDirtyWhenAssociationsReverted():void
		{
			_customer.orders.getItemAt(0).total = 10;
			_customer.orders.revert();
			assertThat(_customer.orders.isDirty, equalTo(false));
		}
		
		[Test]
		public function testIsNotDirtyWhenRemovedAssociationIsNotPersisted():void
		{
			var order:Order = new Order();
			order.total = 20;
			_customer.orders.addItem(order);
			
			_customer.orders.removeItem(order);
			assertThat(_customer.orders.isDirty, equalTo(false));
		}
		
		[Test]
		public function testIsNotDirtyWhenNewAndMarkedForRemoval():void
		{
			var order:Order = new Order();
			order.markForRemoval();
			assertThat(order.isDirty, equalTo(false));
		}
		
		[Test]
		public function testIsDirtyWhenNewAndNotMarkedForRemoval():void
		{
			var order:Order = new Order();
			assertThat(order.isDirty, equalTo(true));
		}
		
		[Test]
		public function testIsDirtyWhenHasPropertyChangesAndIsPersisted():void
		{
			var order:Order = new Order();
			order.id = 1;
			order.found();
			
			order.total = 10;
			assertThat(order.isDirty, equalTo(true));
		}
		
		[Test]
		public function testIsDirtyWhenMarkedForRemovalAndIsPersisted():void
		{
			var order:Order = new Order();
			order.id = 1;
			order.found();
			
			order.markForRemoval();
			assertThat(order.isDirty, equalTo(true));
		}
	}
}