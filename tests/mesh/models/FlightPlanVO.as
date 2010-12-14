package mesh.models
{
	public class FlightPlanVO
	{
		public var id:int;
		public var arriving:AirportVO;
		public var departing:AirportVO;
		public var legs:Array;
		public var alternates:Array;
	}
}