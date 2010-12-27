package mesh
{
	import mesh.models.Airport;
	import mesh.models.AirportVO;
	import mesh.models.Coordinate;
	import mesh.models.FlightPlan;
	
	import org.flexunit.assertThat;
	import org.hamcrest.core.isA;
	import org.hamcrest.object.equalTo;
	import org.hamcrest.object.nullValue;

	public class VOSerializationTests
	{
		private function createAirport():Airport
		{
			var airport:Airport = new Airport();
			airport.id = 1;
			airport.location = new Coordinate(1, 2);
			airport.name = "Reid-Hillview Airport";
			airport.icao = "KRHV";
			return airport;
		}
		
		private function createFlightPlan():FlightPlan
		{
			var flightPlan:FlightPlan = new FlightPlan();
			flightPlan.departing = createAirport();
			flightPlan.arriving = createAirport();
			return flightPlan;
		}
		
		[Test]
		public function testToVOWithoutOptions():void
		{
			var airport:Airport = createAirport();
			
			var vo:Object = airport.toVO();
			assertThat(vo, isA(AirportVO));
			assertThat(vo.id, equalTo(airport.id));
			assertThat(vo.name, equalTo(airport.name));
			assertThat(vo.icao, equalTo(airport.icao));
			assertThat(vo.latitude, equalTo(airport.latitude));
			assertThat(vo.longitude, equalTo(airport.longitude));
		}
		
		[Test]
		public function testToVOInclude():void
		{
			var airport:Airport = createAirport();
			
			var vo:Object = airport.toVO({including:["name", "icao"]});
			assertThat(vo.name, equalTo(airport.name));
			assertThat(vo.icao, equalTo(airport.icao));
			assertThat(vo.latitude, equalTo(NaN));
			assertThat(vo.longitude, equalTo(NaN));
		}
		
		[Test]
		public function testToVOExclude():void
		{
			var airport:Airport = createAirport();
			
			var vo:Object = airport.toVO({excluding:["name", "icao"]});
			assertThat(vo.name, nullValue());
			assertThat(vo.icao, nullValue());
			assertThat(vo.latitude, equalTo(airport.latitude));
			assertThat(vo.longitude, equalTo(airport.longitude));
		}
		
		[Test]
		public function testToVOUsesGeneratesVOForRelationships():void
		{
			var flightPlan:FlightPlan = createFlightPlan();
			
			var vo:Object = flightPlan.toVO();
			assertThat(vo.arriving, isA(AirportVO));
			assertThat(vo.departing, isA(AirportVO));
		}
	}
}