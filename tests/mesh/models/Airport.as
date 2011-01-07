package mesh.models
{
	[BelongsTo(type="mesh.models.FlightPlan")]
	public dynamic class Airport extends NavigationAid
	{
		[VO]
		public static var vo:AirportVO;
		
		[Bindable]
		public var icao:String;
		
		public function Airport()
		{
			super();
		}
		
		override protected function generateTranslationObject():NavigationAidVO
		{
			return new AirportVO();
		}
		
		override public function fromVO(vo:Object, options:Object=null):void
		{
			super.fromVO(vo, options);
			
			var data:AirportVO = AirportVO( vo );
			icao = data.icao;
		}
		
		override public function toVO(options:Object=null):Object
		{
			var data:AirportVO = super.toVO(options) as AirportVO;
			data.icao = icao;
			return data;
		}
	}
}