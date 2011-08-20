package mesh.model
{
	import mesh.Customer;
	import mesh.Name;

	public class EntityTests
	{
		private var _customer:Customer;
		
		[Before]
		public function setup():void
		{
			_customer = new Customer();
			_customer.name = new Name("Jimmy", "Page");
			_customer.age = 67;
		}
	}
}