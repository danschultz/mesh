package mesh
{
	import mesh.models.Airport;
	import mesh.models.FlightPlan;
	
	import mesh.operations.FactoryOperation;
	import mesh.operations.FinishedOperationEvent;
	import mesh.operations.Operation;
	import mesh.operations.ResultOperationEvent;
	
	import org.flexunit.assertThat;
	import org.flexunit.async.Async;
	import org.hamcrest.object.equalTo;

	public class QueryTests
	{
		private var _flightPlan:FlightPlan;
		private var _reidHillview:Airport;
		private var _sanJose:Airport;
		
		[Before(async)]
		public function setup():void
		{
			_reidHillview = new Airport();
			_reidHillview.name = "Reid-Hillview Airport";
			_reidHillview.identifier = "RHV";
			_reidHillview.icao = "KRHV";
			_reidHillview.latitude = 37.3328611;
			_reidHillview.longitude = -121.8198056;
			
			_sanJose = new Airport();
			_sanJose.name = "Norman Y. Mineta San Jose International Airport";
			_sanJose.identifier = "SJC";
			_sanJose.icao = "KSJC";
			_sanJose.latitude = 37.3626667;
			_sanJose.longitude = -121.9291111;
			
			_flightPlan = new FlightPlan();
			_flightPlan.departing = _reidHillview;
			_flightPlan.arriving = _sanJose;
			
			var operation:Operation = new FactoryOperation(_flightPlan.departing.save).then(new FactoryOperation(_flightPlan.arriving.save)).then(new FactoryOperation(_flightPlan.save));
			Async.proceedOnEvent(this, operation, FinishedOperationEvent.FINISHED);
			operation.execute();
		}
		
		[Test(async)]
		public function testIsNotDirtyAfterFind():void
		{
			var result:Airport;
			
			var operation:Operation = Query.entity(Airport).find(_reidHillview.id);
			operation.addEventListener(ResultOperationEvent.RESULT, function(event:ResultOperationEvent):void
			{
				result = event.data;
			});
			operation.addEventListener(FinishedOperationEvent.FINISHED, Async.asyncHandler(this, function(event:FinishedOperationEvent, data:Object = null):void
			{
				assertThat(result.isDirty, equalTo(false));
			}, 250));
		}
		
		[Test(async)]
		public function testIsNotDirtyAfterWhere():void
		{
			var result:Airport;
			
			var operation:Operation = Query.entity(Airport).where({id:_sanJose.id});
			operation.addEventListener(ResultOperationEvent.RESULT, function(event:ResultOperationEvent):void
			{
				result = event.data;
			});
			operation.addEventListener(FinishedOperationEvent.FINISHED, Async.asyncHandler(this, function(event:FinishedOperationEvent, data:Object = null):void
			{
				assertThat(result.isDirty, equalTo(false));
			}, 250));
		}
		
		[Test(async)]
		public function testNonLazyAssociationsNotDirtyAfterFind():void
		{
			var result:FlightPlan;
			
			var operation:Operation = Query.entity(FlightPlan).where({id:_flightPlan.id});
			operation.addEventListener(ResultOperationEvent.RESULT, function(event:ResultOperationEvent):void
			{
				result = event.data;
			});
			operation.addEventListener(FinishedOperationEvent.FINISHED, Async.asyncHandler(this, function(event:FinishedOperationEvent, data:Object = null):void
			{
				assertThat(result.isDirty, equalTo(false));
				assertThat(result.arriving.isDirty, equalTo(false));
				assertThat(result.departing.isDirty, equalTo(false));
				assertThat(result.legs.isDirty, equalTo(false));
			}, 250));
		}
	}
}