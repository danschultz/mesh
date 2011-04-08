package operations
{
	import org.flexunit.assertThat;
	import org.flexunit.asserts.fail;
	import org.flexunit.async.Async;
	import org.hamcrest.object.equalTo;
	import org.hamcrest.object.notNullValue;
	import mesh.operations.FaultOperationEvent;
	import mesh.operations.FinishedOperationEvent;
	import mesh.operations.NetworkOperation;
	import mesh.operations.ResultOperationEvent;

	public class NetworkOperationTests
	{
		private var _operation:NetworkOperation;
		
		[Before]
		public function setup():void
		{
			_operation = new NetworkOperation();
		}
		
		[Test(async)]
		public function testRetries():void
		{
			function handleTimeout(data:Object):void
			{
				fail();
			};
			
			var faultEvent:FaultOperationEvent;
			function handleOperationFault(event:FaultOperationEvent):void
			{
				faultEvent = event;
			};
			
			function handleOperationFinished(event:FinishedOperationEvent, data:Object):void
			{
				assertThat(faultEvent, notNullValue());
				assertThat((event.operation as MockNetworkOperation).attemptsCount, equalTo(5));
				assertThat((event.operation as MockNetworkOperation).requestCount, equalTo(5));
				assertThat(event.successful, equalTo(false));
				assertThat(event.operation.isExecuting, equalTo(false));
			};
			
			var operation:MockNetworkOperation = new MockNetworkOperation(true, false);
			operation.attempts(5).withDelay(50);
			operation.addEventListener(FaultOperationEvent.FAULT, handleOperationFault);
			operation.addEventListener(FinishedOperationEvent.FINISHED, Async.asyncHandler(this, handleOperationFinished, 500, null, handleTimeout));
			operation.execute();
		}
		
		[Test(async)]
		public function testTimeout():void
		{
			function handleTimeout(data:Object):void
			{
				fail();
			};
			
			var faultEvent:FaultOperationEvent;
			function handleOperationFault(event:FaultOperationEvent):void
			{
				faultEvent = event;
			};
			
			function handleOperationFinished(event:FinishedOperationEvent, data:Object):void
			{
				assertThat(faultEvent, notNullValue());
				assertThat((event.operation as NetworkOperation).attemptsCount, equalTo(1));
				assertThat(event.successful, equalTo(false));
				assertThat(event.operation.isExecuting, equalTo(false));
			};
			
			var operation:MockNetworkOperation = new MockNetworkOperation(false, false);
			operation.timeoutAfter(50).milliseconds();
			operation.addEventListener(FaultOperationEvent.FAULT, handleOperationFault);
			operation.addEventListener(FinishedOperationEvent.FINISHED, Async.asyncHandler(this, handleOperationFinished, 200, null, handleTimeout));
			operation.execute();
		}
		
		[Test(async)]
		public function testRequest():void
		{
			function handleTimeout(data:Object):void
			{
				fail();
			};
			
			var resultEvent:ResultOperationEvent;
			function handleOperationResult(event:ResultOperationEvent):void
			{
				resultEvent = event;
			};
			
			function handleOperationFinished(event:FinishedOperationEvent, data:Object):void
			{
				assertThat(resultEvent, notNullValue());
				assertThat(event.successful, equalTo(true));
				assertThat(event.operation.isExecuting, equalTo(false));
			};
			
			var operation:MockNetworkOperation = new MockNetworkOperation(false, true);
			operation.attempts(3).withDelay(50);
			operation.addEventListener(ResultOperationEvent.RESULT, handleOperationResult);
			operation.addEventListener(FinishedOperationEvent.FINISHED, Async.asyncHandler(this, handleOperationFinished, 200, null, handleTimeout));
			operation.execute();
		}
	}
}

import mesh.operations.NetworkOperation;

class MockNetworkOperation extends NetworkOperation
{
	private var _fails:Boolean;
	private var _results:Boolean;
	
	public function MockNetworkOperation(fails:Boolean, results:Boolean)
	{
		_fails = fails;
		_results = results;
	}
	
	override protected function request():void
	{
		_requestCount++;
		
		if (_fails) {
			retry("Error");
		}
		
		if (_results) {
			result({});
		}
	}
	
	private var _requestCount:int = 0;
	public function get requestCount():int
	{
		return _requestCount;
	}
}