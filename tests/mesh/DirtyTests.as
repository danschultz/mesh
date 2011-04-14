package mesh
{
	import mesh.models.Customer;
	import mesh.models.Name;
	import mesh.models.Order;
	
	import org.flexunit.assertThat;
	import org.hamcrest.object.equalTo;

	public class DirtyTests
	{
		private var _customer:Customer;
		
		[Before]
		public function setup():void
		{
			// this should return a customer from a test file
			_customer = new Customer();
			_customer.id = 1;
			_customer.age = 21;
			_customer.name = new Name("John", "Doe");
			
			var order:Order = new Order();
			order.id = 1;
			_customer.orders.add(order);
			
			_customer.callback("afterFind");
		}
		
		[Test]
		public function testWhatWas():void
		{
			var oldAge:int = _customer.age;
			_customer.age++;
			assertThat(_customer.whatWas("age"), equalTo(oldAge));
		}
		
		[Test]
		public function testWhatWasReturnsSavedValueAfterSave():void
		{
			var newAge:int = ++_customer.age;
			_customer.callback("afterSave");
			assertThat(_customer.whatWas("age"), equalTo(newAge));
		}
		
		[Test]
		public function testDirtyUsesEqualsOnValueObjects():void
		{
			_customer.name = new Name(_customer.name.firstName, _customer.name.lastName);
			assertThat(_customer.isDirty, equalTo(false));
		}
		
		[Test]
		public function testIsDirtyWhenPropertyChanges():void
		{
			_customer.name = new Name("Jimmy", "Paige");
			assertThat(_customer.isDirty, equalTo(true));
		}
		
		[Test]
		public function testIsNotDirtyWhenReverted():void
		{
			_customer.age++;
			_customer.name = new Name("Jimmy", "Paige");
			_customer.revert();
			assertThat(_customer.isDirty, equalTo(false));
		}
		
		[Test]
		public function testAssociationIsNotDirtyWhenReverted():void
		{
			_customer.orders.getItemAt(0).total = 10;
			_customer.orders.revert();
			assertThat(_customer.orders.isDirty, equalTo(false));
		}
		
		[Test]
		public function testAssociationIsNotDirtyWhenRemovedItemIsNotPersisted():void
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
			_customer.age++;
			assertThat(_customer.isDirty, equalTo(true));
		}
		
		[Test]
		public function testIsDirtyWhenMarkedForRemovalAndIsPersisted():void
		{
			_customer.id = 1;
			_customer.markForRemoval();
			assertThat(_customer.isDirty, equalTo(true));
		}
	}
}