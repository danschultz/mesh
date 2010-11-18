package operations
{
	import org.flexunit.assertThat;
	import org.hamcrest.object.equalTo;
	import org.hamcrest.object.notNullValue;
	import org.hamcrest.object.nullValue;

	public class MethodOperationTests
	{
		[Test]
		public function testExecuteWithoutRTE():void
		{
			var resultEvent:ResultOperationEvent;
			function handleOperationResult(event:ResultOperationEvent):void
			{
				resultEvent = event;
			};
			
			var finishedEvent:FinishedOperationEvent;
			function handleOperationFinish(event:FinishedOperationEvent):void
			{
				finishedEvent = event;
			};
			
			var str:String = "Hello World";
			var operation:MethodOperation = new MethodOperation(str.substr, 0, 5);
			operation.addEventListener(ResultOperationEvent.RESULT, handleOperationResult);
			operation.addEventListener(FinishedOperationEvent.FINISHED, handleOperationFinish);
			operation.execute();
			
			assertThat(resultEvent.data, equalTo(str.substr(0, 5)));
			assertThat(finishedEvent.successful, equalTo(true));
			assertThat(operation.isExecuting, equalTo(false));
		}
		
		[Test]
		public function testExecuteWithRTE():void
		{
			var resultEvent:ResultOperationEvent;
			function handleOperationResult(event:ResultOperationEvent):void
			{
				resultEvent = event;
			};
			
			var faultEvent:FaultOperationEvent;
			function handleOperationFault(event:FaultOperationEvent):void
			{
				faultEvent = event;
			};
			
			var finishedEvent:FinishedOperationEvent;
			function handleOperationFinish(event:FinishedOperationEvent):void
			{
				finishedEvent = event;
			};
			
			var str:String = "Hello World";
			var operation:MethodOperation = new MethodOperation(str.substr, 0, 5, 10);
			operation.addEventListener(ResultOperationEvent.RESULT, handleOperationResult);
			operation.addEventListener(FaultOperationEvent.FAULT, handleOperationFault);
			operation.addEventListener(FinishedOperationEvent.FINISHED, handleOperationFinish);
			operation.execute();
			
			assertThat(resultEvent, nullValue());
			assertThat(faultEvent, notNullValue());
			assertThat(finishedEvent.successful, equalTo(false));
			assertThat(operation.isExecuting, equalTo(false));
		}
	}
}