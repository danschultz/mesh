package mesh.models
{
	import mx.collections.ArrayCollection;

	public class FlightPlanVO
	{
		[Entity]
		public static var entity:FlightPlan;
		
		public var id:int;
		public var arriving:AirportVO;
		public var arrivingId:int;
		public var departing:AirportVO;
		public var departingId:int;
		public var legs:ArrayCollection;
		public var alternates:Array;
	}
}