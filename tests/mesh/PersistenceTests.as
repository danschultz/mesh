package mesh
{
	import mesh.models.Address;
	import mesh.models.Customer;
	import mesh.models.Name;
	import mesh.models.Order;
	
	import operations.FaultOperationEvent;
	import operations.FinishedOperationEvent;
	import operations.Operation;
	
	import org.flexunit.assertThat;
	import org.flexunit.asserts.fail;
	import org.flexunit.async.Async;
	import org.hamcrest.object.equalTo;

	public class PersistenceTests
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
		public function testSaveNew():void
		{
			var assertion:Function = function(event:FinishedOperationEvent, data:Object):void
			{
				assertThat(_customer.isPersisted, equalTo(true));
				assertThat(_customer.isDirty, equalTo(false));
			};
			
			var operation:Operation = _customer.save();
			operation.addEventListener(FinishedOperationEvent.FINISHED, Async.asyncHandler(this, assertion, 100));
			operation.addEventListener(FaultOperationEvent.FAULT, function(event:FaultOperationEvent):void
			{
				fail(event.summary);
			});
		}
		
		[Test(async)]
		public function testSaveUpdates():void
		{
			var assertion:Function = function(event:FinishedOperationEvent, data:Object):void
			{
				assertThat(_customer.isDirty, equalTo(false));
			};
			assertion = Async.asyncHandler(this, assertion, 250);
			
			var operation:Operation = _customer.save();
			operation.addEventListener(FinishedOperationEvent.FINISHED, function(event:FinishedOperationEvent):void
			{
				_customer.fullName = new Name("Jane", "Doe");
				_customer.age = 18;
				
				var operation:Operation = _customer.save() as Operation;
				operation.addEventListener(FinishedOperationEvent.FINISHED, assertion);
			});
			operation.addEventListener(FaultOperationEvent.FAULT, function(event:FaultOperationEvent):void
			{
				fail(event.summary);
			});
		}
		
		[Test(async)]
		public function testSaveNewAssociations():void
		{
			var order1:Order = new Order();
			_customer.orders.addItem(order1);
			
			var order2:Order = new Order();
			_customer.orders.addItem(order2);
			
			var assertion:Function = function(event:FinishedOperationEvent, data:Object):void
			{
				assertThat(order1.isPersisted, equalTo(true));
				assertThat(order1.isDirty, equalTo(false));
				assertThat(order2.isPersisted, equalTo(true));
				assertThat(order2.isDirty, equalTo(false));
			};
			
			var operation:Operation = _customer.save();
			operation.addEventListener(FinishedOperationEvent.FINISHED, Async.asyncHandler(this, assertion, 100));
			operation.addEventListener(FaultOperationEvent.FAULT, function(event:FaultOperationEvent):void
			{
				fail(event.summary);
			});
		}
		
		[Test(async)]
		public function testSaveUpdatedAssociations():void
		{
			var order1:Order = new Order();
			_customer.orders.addItem(order1);
			
			var order2:Order = new Order();
			_customer.orders.addItem(order2);
			
			var assertion:Function = function(event:FinishedOperationEvent, data:Object):void
			{
				assertThat(order1.isDirty, equalTo(false));
				assertThat(order2.isDirty, equalTo(false));
			};
			assertion = Async.asyncHandler(this, assertion, 250);
			
			var operation:Operation = _customer.save();
			operation.addEventListener(FinishedOperationEvent.FINISHED, function(event:FinishedOperationEvent):void
			{
				order2.total = 10;
				
				var operation:Operation = _customer.save() as Operation;
				operation.addEventListener(FinishedOperationEvent.FINISHED, assertion);
			});
			operation.addEventListener(FaultOperationEvent.FAULT, function(event:FaultOperationEvent):void
			{
				fail(event.summary);
			});
		}
		
		[Test(async)]
		public function testSaveDestroyedAssociations():void
		{
			var order1:Order = new Order();
			_customer.orders.addItem(order1);
			
			var order2:Order = new Order();
			_customer.orders.addItem(order2);
			
			var order3:Order = new Order();
			_customer.orders.addItem(order3);
			
			var order4:Order = new Order();
			_customer.orders.addItem(order4);
			
			var assertion:Function = function(event:FinishedOperationEvent, data:Object):void
			{
				assertThat(order1.isDestroyed, equalTo(true));
				assertThat(order3.isDestroyed, equalTo(true));
				assertThat(order4.isDestroyed, equalTo(true));
				assertThat(order2.isPersisted, equalTo(true));
				assertThat(_customer.orders.hasUnsavedRemovedEntities, equalTo(false));
			};
			assertion = Async.asyncHandler(this, assertion, 250);
			
			var operation:Operation = _customer.save();
			operation.addEventListener(FinishedOperationEvent.FINISHED, function(event:FinishedOperationEvent):void
			{
				_customer.orders.removeItem(order1);
				_customer.orders.removeItem(order3);
				_customer.orders.removeItem(order4);
				
				var operation:Operation = _customer.save() as Operation;
				operation.addEventListener(FinishedOperationEvent.FINISHED, assertion);
			});
			operation.addEventListener(FaultOperationEvent.FAULT, function(event:FaultOperationEvent):void
			{
				fail(event.summary);
			});
		}
	}
}