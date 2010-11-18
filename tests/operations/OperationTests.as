package operations
{
	import org.flexunit.assertThat;
	import org.hamcrest.object.equalTo;
	import org.hamcrest.object.notNullValue;
	import org.hamcrest.object.nullValue;
	
	public class OperationTests
	{
		private var _operation:MockOperation;
		
		[Before]
		public function setup():void
		{
			_operation = new MockOperation();
		}
		
		[Test]
		public function testCancelWhenNotIdle():void
		{
			var canceledFired:Boolean;
			function handleOperationCanceled(event:OperationEvent):void
			{
				canceledFired = true;
			};
			
			var finishedFired:Boolean;
			function handleOperationFinished(event:FinishedOperationEvent):void
			{
				finishedFired = true;
			};
			
			_operation.addEventListener(OperationEvent.CANCELED, handleOperationCanceled);
			_operation.addEventListener(FinishedOperationEvent.FINISHED, handleOperationFinished);
			_operation.cancel();
			
			assertThat(canceledFired, equalTo(false));
			assertThat(finishedFired, equalTo(false));
		}
		
		[Test]
		public function testCancelWhenExecuting():void
		{
			var canceledFired:Boolean;
			function handleOperationCanceled(event:OperationEvent):void
			{
				canceledFired = true;
			};
			
			var finishedFired:Boolean;
			function handleOperationFinished(event:FinishedOperationEvent):void
			{
				finishedFired = true;
			};
			
			_operation.addEventListener(OperationEvent.CANCELED, handleOperationCanceled);
			_operation.addEventListener(FinishedOperationEvent.FINISHED, handleOperationFinished);
			_operation.execute();
			_operation.cancel();
			
			assertThat(canceledFired, equalTo(true));
			assertThat(finishedFired, equalTo(true));
			assertThat(_operation.isExecuting, equalTo(false));
		}
		
		[Test]
		public function testExecuteWhenIdle():void
		{
			var executeFired:Boolean;
			function handleOperationExecuted(event:OperationEvent):void
			{
				executeFired = true;
			}
			
			_operation.addEventListener(OperationEvent.EXECUTED, handleOperationExecuted);
			_operation.execute();
			
			assertThat(executeFired, equalTo(true));
			assertThat(_operation.isExecuting, equalTo(true));
		}
		
		[Test]
		public function testExecuteWhenExecuting():void
		{
			_operation.execute();
			
			var executeFired:Boolean;
			function handleOperationExecuted(event:OperationEvent):void
			{
				executeFired = true;
			}
			
			_operation.addEventListener(OperationEvent.EXECUTED, handleOperationExecuted);
			_operation.execute();
			
			assertThat(executeFired, equalTo(false));
			assertThat(_operation.isExecuting, equalTo(true));
		}
		
		[Test]
		public function testFault():void
		{
			var faultEvent:FaultOperationEvent;
			function handleOperationFault(event:FaultOperationEvent):void
			{
				faultEvent = event;
			};
			
			var finishedEvent:FinishedOperationEvent;
			function handleOperationFinished(event:FinishedOperationEvent):void
			{
				finishedEvent = event;
			}
			
			_operation.addEventListener(FaultOperationEvent.FAULT, handleOperationFault);
			_operation.addEventListener(FinishedOperationEvent.FINISHED, handleOperationFinished);
			_operation.execute();
			_operation.mimicFault("Error", "Error");
			
			assertThat(faultEvent, notNullValue());
			assertThat(finishedEvent.successful, equalTo(false));
			assertThat(_operation.isExecuting, equalTo(false));
		}
		
		[Test]
		public function testResultWithoutRTE():void
		{
			var resultEvent:ResultOperationEvent;
			function handleOperationResult(event:ResultOperationEvent):void
			{
				resultEvent = event;
			};
			
			var finishedEvent:FinishedOperationEvent;
			function handleOperationFinished(event:FinishedOperationEvent):void
			{
				finishedEvent = event;
			}
			
			var resultData:Object = {};
			_operation.addEventListener(ResultOperationEvent.RESULT, handleOperationResult);
			_operation.addEventListener(FinishedOperationEvent.FINISHED, handleOperationFinished);
			_operation.execute();
			_operation.mimicResult(resultData, false);
			
			assertThat(resultEvent.data, equalTo(resultData));
			assertThat(finishedEvent.successful, equalTo(true));
			assertThat(_operation.isExecuting, equalTo(false));
		}
		
		[Test]
		public function testResultWithRTE():void
		{
			var faultEvent:FaultOperationEvent;
			function handleOperationFault(event:FaultOperationEvent):void
			{
				faultEvent = event;
			};
			
			var resultEvent:ResultOperationEvent;
			function handleOperationResult(event:ResultOperationEvent):void
			{
				resultEvent = event;
			};
			
			var finishedEvent:FinishedOperationEvent;
			function handleOperationFinished(event:FinishedOperationEvent):void
			{
				finishedEvent = event;
			}
			
			_operation.addEventListener(FaultOperationEvent.FAULT, handleOperationFault);
			_operation.addEventListener(ResultOperationEvent.RESULT, handleOperationResult);
			_operation.addEventListener(FinishedOperationEvent.FINISHED, handleOperationFinished);
			_operation.execute();
			_operation.mimicResult({}, true);
			
			assertThat(resultEvent, nullValue());
			assertThat(faultEvent, notNullValue());
			assertThat(finishedEvent.successful, equalTo(false));
			assertThat(_operation.isExecuting, equalTo(false));
		}
	}
}