package mesh.models
{
	import mesh.Entity;
	import mesh.adaptors.MockAdaptor;
	
	[BelongsTo(type="mesh.models.FlightPlan")]
	public dynamic class NavigationAid extends Entity
	{
		[ServiceAdaptor]
		public static var adaptor:MockAdaptor;
		
		[VO]
		public static var vo:NavigationAidVO;
		
		[Bindable]
		public var name:String;
		
		[Bindable]
		public var identifier:String;
		
		public function NavigationAid()
		{
			super();
			NavigationAidVO;
		}
		
		public static function from(data:NavigationAidVO):NavigationAid
		{
			if (data is AirportVO) {
				return new Airport();
			}
			return new NavigationAid();
		}
		
		protected function generateTranslationObject():NavigationAidVO
		{
			return new NavigationAidVO();
		}
		
		override public function translateFrom(object:Object):void
		{
			var data:NavigationAidVO = NavigationAidVO( object );
			id = data.id;
			location = new Coordinate(data.latitude, data.longitude);
			name = data.name;
		}
		
		override public function translateTo():Object
		{
			var data:NavigationAidVO = generateTranslationObject();
			data.id = id;
			data.latitude = location.latitude;
			data.longitude = location.longitude;
			data.name = name;
			return data;
		}
		
		override public function toVO(options:Object = null):Object
		{
			if (options == null) {
				options = {};
			}
			if (!options.hasOwnProperty("excluding")) {
				options.excluding = [];
			}
			options.excluding.push("location");
			return super.toVO(options);
		}
		
		private var _location:Coordinate;
		[Bindable]
		[ComposedOf(mapping="latitude, longitude")]
		public function get location():Coordinate
		{
			return _location;
		}
		public function set location(value:Coordinate):void
		{
			_location = value;
		}
	}
}