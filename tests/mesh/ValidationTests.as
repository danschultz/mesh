package mesh
{
	import mesh.models.Address;
	import mesh.models.Customer;
	import mesh.models.Name;
	
	import mesh.operations.FaultOperationEvent;
	import mesh.operations.FinishedOperationEvent;
	import mesh.operations.Operation;
	
	import org.flexunit.assertThat;
	import org.flexunit.async.Async;
	import org.hamcrest.collection.arrayWithSize;
	import org.hamcrest.collection.emptyArray;
	import org.hamcrest.object.equalTo;

	public class ValidationTests
	{
		[Test]
		public function testValidatePasses():void
		{
			var customer:Customer = new Customer();
			customer.fullName = new Name("John", "Doe");
			customer.address = new Address("1 Infinite Loop", "Cupertino");
			customer.age = 10;
			
			assertThat(customer.isValid(), equalTo(true));
			assertThat(customer.isInvalid(), equalTo(false));
			assertThat(customer.errors.toArray(), emptyArray());
		}
		
		[Test]
		public function testValidateFails():void
		{
			var customer:Customer = new Customer();
			customer.fullName = new Name("", "");
			customer.address = new Address("", "");
			customer.age = 0;
			
			assertThat(customer.isValid(), equalTo(false));
			assertThat(customer.isInvalid(), equalTo(true));
			assertThat(customer.errors.toArray(), arrayWithSize(9));
		}
		
		[Test(async)]
		public function testSaveFaultsOnErrors():void
		{
			var customer:Customer = new Customer();
			customer.fullName = new Name("", "");
			customer.address = new Address("", "");
			customer.age = 0;
			
			var assertion:Function = function(event:FaultOperationEvent, data:Object):void
			{
				assertThat(customer.errors.isEmpty, equalTo(false));
			};
			
			var operation:Operation = customer.save(true);
			operation.addEventListener(FaultOperationEvent.FAULT, Async.asyncHandler(this, assertion, 100));
		}
		
		[Test(async)]
		public function testSaveDoesNotHaveErrorsWhenSkippingValidations():void
		{
			var customer:Customer = new Customer();
			customer.fullName = new Name("", "");
			customer.address = new Address("", "");
			customer.age = 0;
			
			var assertion:Function = function(event:FinishedOperationEvent, data:Object):void
			{
				assertThat(customer.errors.isEmpty, equalTo(true));
			};
			
			var operation:Operation = customer.save(false);
			operation.addEventListener(FinishedOperationEvent.FINISHED, Async.asyncHandler(this, assertion, 100));
		}
	}
}