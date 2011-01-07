package mesh
{
	import mesh.models.Account;
	import mesh.models.Address;
	import mesh.models.Car;
	import mesh.models.Customer;
	import mesh.models.Name;
	import mesh.models.Order;
	import mesh.models.Person;
	
	import org.flexunit.assertThat;
	import org.hamcrest.collection.array;
	import org.hamcrest.collection.arrayWithSize;
	import org.hamcrest.collection.emptyArray;
	import org.hamcrest.collection.hasItems;
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
			assertThat(_customer.hasDirtyAssociations, equalTo(false));
			assertThat(_customer.hasPropertyChanges, equalTo(true));
			assertThat(_customer.isDirty, equalTo(true));
		}
		
		[Test]
		public function testIsNotDirtyWhenReverted():void
		{
			_customer.age = 10;
			_customer.firstName = "Jane";
			_customer.address = new Address("1 Infinite Loop", "Cupertino");
			
			_customer.revert();
			assertThat(_customer.hasDirtyAssociations, equalTo(false));
			assertThat(_customer.hasPropertyChanges, equalTo(false));
			assertThat(_customer.isDirty, equalTo(false));
		}
		
		[Test]
		public function testIsNotDirtyWhenAssociationsReverted():void
		{
			_customer.orders.getItemAt(0).total = 10;
			_customer.revert();
			assertThat(_customer.isDirty, equalTo(false));
		}
		
		[Test]
		public function testDoesNotHaveDirtyAssociations():void
		{
			var order:Order = _customer.orders.getItemAt(0);
			order.total = 10;
			order.persisted();
			assertThat(_customer.hasDirtyAssociations, equalTo(false));
		}
		
		[Test]
		public function testIsNotDirtyWhenRemovedAssociationIsNotPersisted():void
		{
			var order:Order = new Order();
			order.total = 20;
			_customer.orders.addItem(order);
			
			_customer.orders.removeItem(order);
			assertThat(_customer.ordersAssociation.isDirty, equalTo(false));
			assertThat(_customer.hasDirtyAssociations, equalTo(false));
		}
		
		[Test]
		public function testIsDirtyWhenAssociationIsDirty():void
		{
			_customer.orders.getItemAt(0).total = 10;
			assertThat(_customer.hasPropertyChanges, equalTo(false));
			assertThat(_customer.hasDirtyAssociations, equalTo(true));
			assertThat(_customer.isDirty, equalTo(true));
		}
		
		[Test]
		public function testFindDirtyEntitiesReturnsEmptySetWhenNotDirty():void
		{
			var result:Array = _customer.findDirtyEntities().toArray();
			assertThat(result, emptyArray());
		}
		
		[Test]
		public function testFindDirtyEntitiesDoesNotReturnEntitiesFromNonDirtyAssociations():void
		{
			_customer.age = 25;
			var result:Array = _customer.findDirtyEntities().toArray();
			assertThat(result, array(_customer));
		}
		
		[Test]
		public function testFindDirtyEntitiesReturnsEntitiesFromDirtyAssociations():void
		{
			_customer.age = 25;
			_customer.orders.getItemAt(0).total = 5;
			_customer.account.number = "000-001";
			
			var result:Array = _customer.findDirtyEntities().toArray();
			assertThat(result, arrayWithSize(3));
			assertThat(result, hasItems(_customer, _customer.orders.getItemAt(0)));
		}
		
		[Test]
		public function testAssociationsIsDirtyWithCircularReferences():void
		{
			var jack:Person = new Person();
			jack.id = 1;
			jack.firstName = "Jack";
			jack.persisted();
			
			var jill:Person = new Person();
			jill.id = 2;
			jill.firstName = "Jill";
			jill.persisted();
			
			jack.partner = jill;
			jill.partner = jack;
			
			assertThat(jack.hasDirtyAssociations, equalTo(true));
			assertThat(jill.hasDirtyAssociations, equalTo(true));
		}
		
		[Test]
		public function testAssociationsIsNotDirtyWithCircularReferences():void
		{
			var jack:Person = new Person();
			jack.id = 1;
			jack.firstName = "Jack";
			
			var jill:Person = new Person();
			jill.id = 2;
			jill.firstName = "Jill";
			
			jack.partner = jill;
			jill.partner = jack;
			
			jack.found();
			jill.found();
			
			assertThat(jack.hasDirtyAssociations, equalTo(false));
			assertThat(jill.hasDirtyAssociations, equalTo(false));
		}
	}
}