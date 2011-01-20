package mesh
{
	import mesh.models.Airport;
	import mesh.models.AirportVO;
	
	import org.flexunit.assertThat;
	import org.hamcrest.object.equalTo;
	
	public class VODeserializationTests
	{
		private function createAirportVO():AirportVO
		{
			var vo:AirportVO = new AirportVO();
			vo.id = 1;
			vo.latitude = 1;
			vo.longitude = 2;
			vo.name = "Reid-Hillview Airport";
			vo.icao = "KRHV";
			return vo;
		}
		
		[Ignore]
		[Test]
		public function testToVOWithoutOptions():void
		{
			var vo:AirportVO = createAirportVO();
			var airport:Airport = new Airport();
			airport.fromVO(vo);
			
			assertThat(airport.id, equalTo(vo.id));
			assertThat(airport.name, equalTo(vo.name));
			assertThat(airport.icao, equalTo(vo.icao));
			assertThat(airport.latitude, equalTo(vo.latitude));
			assertThat(airport.longitude, equalTo(vo.longitude));
		}
	}
}