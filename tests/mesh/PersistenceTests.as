package mesh
{
	import mesh.models.Address;
	import mesh.models.Customer;
	import mesh.models.Name;
	
	import operations.FinishedOperationEvent;
	import operations.Operation;
	
	import org.flexunit.assertThat;
	import org.flexunit.async.Async;
	import org.hamcrest.object.equalTo;

	public class PersistenceTests
	{
		[Before]
		public function setup():void
		{
			
		}
		
		[Test(async)]
		public function testSaveNew():void
		{
			var assertion:Function = function(event:FinishedOperationEvent, data:Object):void
			{
				assertThat(customer.isPersisted, equalTo(true));
				assertThat(customer.isDirty, equalTo(false));
			};
			
			var customer:Customer = new Customer();
			customer.fullName = new Name("John", "Doe");
			customer.address = new Address("2306 Zanker Rd", "San Jose");
			customer.age = 21;
			
			var operation:Operation = customer.save() as Operation;
			operation.addEventListener(FinishedOperationEvent.FINISHED, Async.asyncHandler(this, assertion, 100));
		}
		
		[Test(async)]
		public function testSaveUpdates():void
		{
			var assertion:Function = function(event:FinishedOperationEvent, data:Object):void
			{
				assertThat(customer.isDirty, equalTo(false));
			};
			
			var customer:Customer = new Customer();
			customer.fullName = new Name("John", "Doe");
			customer.address = new Address("2306 Zanker Rd", "San Jose");
			customer.age = 21;
			
			assertion = Async.asyncHandler(this, assertion, 250);
			
			var operation:Operation = customer.save() as Operation;
			operation.addEventListener(FinishedOperationEvent.FINISHED, function(event:FinishedOperationEvent):void
			{
				customer.fullName = new Name("Jane", "Doe");
				customer.age = 18;
				
				var operation:Operation = customer.save() as Operation;
				operation.addEventListener(FinishedOperationEvent.FINISHED, assertion);
			});
		}
	}
}