package mesh
{
	import mesh.associations.HasOneAssociation;
	import mesh.models.Car;
	import mesh.models.Customer;
	
	import org.flexunit.assertThat;
	import org.hamcrest.object.equalTo;

	public class HasOneAssociationTests
	{
		private var _customer:Customer;
		
		[Before]
		public function setup():void
		{
			_customer = new Customer();
		}
		
		[Test]
		public function testAssociatingDestroyedEntityIsDirty():void
		{
			var car:Car = new Car();
			car.id = 3;
			car.make = "Mazda";
			car.callback("afterDestroy");
			
			_customer.primaryCar = car;
			assertThat(_customer.primaryCar.isDirty, equalTo(true));
		}
		
		[Test]
		public function testDestroyedEntityIsNewWhenAssociating():void
		{
			var car:Car = new Car();
			car.id = 3;
			car.make = "Mazda";
			car.callback("afterDestroy");
			
			_customer.primaryCar = car;
			assertThat(order.isNew, equalTo(true));
			assertThat(order.isDirty, equalTo(true));
		}
		
	}
}