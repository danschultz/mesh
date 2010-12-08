package operations
{
	import org.flexunit.assertThat;
	import org.hamcrest.object.equalTo;
	import org.hamcrest.object.notNullValue;
	import org.hamcrest.object.nullValue;

	public class CompoundOperationTests
	{
		private var _compound:CompoundOperation;
		
		[Before]
		public function setup():void
		{
			_compound = new CompoundOperation();
		}
		
		[Test]
		public function testExecutingFinishedWithFault():void
		{
			var operation1:MockOperation = new MockOperation();
			var operation2:MockOperation = new MockOperation();
			var operation3:MockOperation = new MockOperation();
			
			var canceledEvent:OperationEvent;
			function handleOperationCanceled(event:OperationEvent):void
			{
				canceledEvent = event;
			};
			
			var faultEvent:FaultOperationEvent;
			function handleOperationFault(event:FaultOperationEvent):void
			{
				faultEvent = event;
			};
			
			var finishedEvent:FinishedOperationEvent;
			function handleOperationFinished(event:FinishedOperationEvent):void
			{
				finishedEvent = event;
			};
			
			var compound:MockCompoundOperation = new MockCompoundOperation(new <Operation>[operation1, operation2, operation3]);
			compound.addEventListener(OperationEvent.CANCELED, handleOperationCanceled);
			compound.addEventListener(FaultOperationEvent.FAULT, handleOperationFault);
			compound.addEventListener(FinishedOperationEvent.FINISHED, handleOperationFinished);
			compound.execute();
			
			operation1.mimicResult({}, false);
			operation2.mimicResult({}, false);
			operation3.mimicFault("", "");
			
			assertThat(canceledEvent, notNullValue());
			assertThat(faultEvent, nullValue());
			assertThat(finishedEvent.successful, equalTo(false));
			assertThat(compound.isExecuting, equalTo(false));
		}
		
		[Test]
		public function testExecutingFinishedWithResult():void
		{
			var operation1:MockOperation = new MockOperation();
			var operation2:MockOperation = new MockOperation();
			var operation3:MockOperation = new MockOperation();
			
			var canceledEvent:OperationEvent;
			function handleOperationCanceled(event:OperationEvent):void
			{
				canceledEvent = event;
			};
			
			var finishedEvent:FinishedOperationEvent;
			function handleOperationFinished(event:FinishedOperationEvent):void
			{
				finishedEvent = event;
			};
			
			var compound:MockCompoundOperation = new MockCompoundOperation(new <Operation>[operation1, operation2, operation3]);
			compound.addEventListener(OperationEvent.CANCELED, handleOperationCanceled);
			compound.addEventListener(FinishedOperationEvent.FINISHED, handleOperationFinished);
			compound.execute();
			
			operation1.mimicResult({}, false);
			operation2.mimicResult({}, false);
			operation3.mimicResult({}, false);
			
			assertThat(canceledEvent, nullValue());
			assertThat(finishedEvent.successful, equalTo(true));
			assertThat(compound.isExecuting, equalTo(false));
		}
		
		[Test]
		public function testExecutingWithoutOperations():void
		{
			var finishedEvent:FinishedOperationEvent;
			function handleOperationFinished(event:FinishedOperationEvent):void
			{
				finishedEvent = event;
			};
			
			var compound:MockCompoundOperation = new MockCompoundOperation();
			compound.addEventListener(FinishedOperationEvent.FINISHED, handleOperationFinished);
			compound.execute();
			
			assertThat(finishedEvent.successful, equalTo(true));
			assertThat(compound.isExecuting, equalTo(false));
		}
	}
}

import operations.CompoundOperation;
import operations.Operation;

class MockCompoundOperation extends CompoundOperation
{
	public function MockCompoundOperation(operations:Vector.<Operation> = null)
	{
		super(operations);
	}
	
	override protected function startExecution():void
	{
		executeOperation(nextOperation(finishedOperationsCount));
	}
	
	override protected function nextOperation(finishedOperationsCount:int):Operation
	{
		return operationSet.toArray()[finishedOperationsCount];
	}
}