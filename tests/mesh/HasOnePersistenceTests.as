package mesh
{
	import mesh.models.Account;
	import mesh.models.Address;
	import mesh.models.Customer;
	import mesh.models.Name;
	
	import operations.FaultOperationEvent;
	import operations.FinishedOperationEvent;
	import operations.Operation;
	
	import org.flexunit.assertThat;
	import org.flexunit.asserts.fail;
	import org.flexunit.async.Async;
	import org.hamcrest.object.equalTo;
	import org.hamcrest.object.nullValue;

	public class HasOnePersistenceTests
	{
		private var _customer:Customer;
		
		[Before]
		public function setup():void
		{
			_customer = new Customer();
			_customer.fullName = new Name("John", "Doe");
			_customer.address = new Address("2306 Zanker Rd", "San Jose");
			_customer.age = 21;
		}
		
		[Test(async)]
		public function testSaveNewTarget():void
		{
			var assertion:Function = function(event:FinishedOperationEvent, data:Object):void
			{
				assertThat(_customer.account.target.isDirty, equalTo(false));
				assertThat(_customer.account.isDirty, equalTo(false));
			};
			
			_customer.account = new Account();
			var operation:Operation = _customer.account.save();
			operation.addEventListener(FinishedOperationEvent.FINISHED, Async.asyncHandler(this, assertion, 100));
			operation.addEventListener(FaultOperationEvent.FAULT, function(event:FaultOperationEvent):void
			{
				fail(event.summary);
			});
		}
		
		[Test(async)]
		public function testSaveReplacedTarget():void
		{
			_customer.account = new Account();
			var operation:Operation = _customer.account.save();
			operation.addEventListener(FinishedOperationEvent.FINISHED, function(event:FinishedOperationEvent):void
			{
				_customer.account = new Account();
				
				var assertion:Function = function(event:FinishedOperationEvent, data:Object):void
				{
					assertThat(_customer.account.target.isDirty, equalTo(false));
					assertThat(_customer.account.isDirty, equalTo(false));
				};
				assertion = Async.asyncHandler(this, assertion, 100);
				
				var operation:Operation = _customer.account.save();
				operation.addEventListener(FinishedOperationEvent.FINISHED, assertion);
			});
			operation.addEventListener(FaultOperationEvent.FAULT, function(event:FaultOperationEvent):void
			{
				fail(event.summary);
			});
		}
		
		[Test(async)]
		public function testDestroyingTargetSetsAssociationsTargetToUndefined():void
		{
			_customer.account = new Account();
			var operation:Operation = _customer.account.save();
			operation.addEventListener(FinishedOperationEvent.FINISHED, function(event:FinishedOperationEvent):void
			{
				var assertion:Function = function(event:FinishedOperationEvent, data:Object):void
				{
					assertThat(_customer.account.target, nullValue());
					assertThat(_customer.account.isDirty, equalTo(false));
				};
				assertion = Async.asyncHandler(this, assertion, 100);
				
				var operation:Operation = _customer.account.destroy();
				operation.addEventListener(FinishedOperationEvent.FINISHED, assertion);
			});
			operation.addEventListener(FaultOperationEvent.FAULT, function(event:FaultOperationEvent):void
			{
				fail(event.summary);
			});
		}
	}
}