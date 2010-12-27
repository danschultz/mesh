package mesh.models
{
	public class FlightPlanVO
	{
		[Entity]
		public static var entity:FlightPlan;
		
		public var id:int;
		public var arriving:AirportVO;
		public var departing:AirportVO;
		public var legs:Array;
		public var alternates:Array;
	}
}