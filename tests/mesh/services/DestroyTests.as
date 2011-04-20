package mesh.services
{
	import mesh.Customer;
	import mesh.Mesh;
	import mesh.Name;
	
	import org.flexunit.asserts.fail;

	public class DestroyTests
	{
		private var _customer:Customer;
		
		[Before]
		public function setup():void
		{
			_customer = new Customer();
			_customer.name = new Name("Jimmy", "Page");
			_customer.age = 67;
			_customer.save();
		}
		
		[Test]
		public function testDestroy():void
		{
			_customer.destroy().execute();
			
			var query:Request = Mesh.service(Customer).find(_customer.id).execute({
				fault:function(data:Object):void
				{
					
				},
				success:function():void
				{
					fail();
				}
			});
		}
	}
}