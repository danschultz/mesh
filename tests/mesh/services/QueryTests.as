package mesh.services
{
	import mesh.Customer;
	import mesh.Name;
	
	import org.flexunit.assertThat;
	import org.flexunit.asserts.fail;
	import org.hamcrest.object.equalTo;

	public class QueryTests
	{
		private var _service:TestService;
		private var _customer1:Customer;
		private var _customer2:Customer;
		
		[Before]
		public function setup():void
		{
			_service = new TestService(Customer);
			
			_customer1 = new Customer();
			_customer1.name = new Name("Jimmy", "Page");
			_customer1.age = 67;
			
			_customer2 = new Customer();
			_customer2.name = new Name("Thom", "Yorke");
			_customer2.age = 42;
			_service.insert([_customer1, _customer2]).execute({fault:fault});
		}
		
		private function fault(data:Object):void
		{
			fail(data.toString());
		}
		
		[Test]
		public function testFindOne():void
		{
			var customer:QueryRequest = _service.findOne(_customer1.id);
			customer.execute({fault:fault});
			assertCustomer(customer, _customer1);
		}
		
		[Test]
		public function testFindMany():void
		{
			var customers:ListQueryRequest = _service.findMany(_customer1.id, _customer2.id);
			customers.execute({fault:fault});
			
			assertThat(customers.length, equalTo(2));
			assertCustomer(customers.getItemAt(0), _customer1);
			assertCustomer(customers.getItemAt(1), _customer2);
		}
		
		private function assertCustomer(customer:*, against:Customer):void
		{
			assertThat(customer.id, equalTo(against.id));
			assertThat(customer.name.equals(against.name), equalTo(true));
		}
	}
}