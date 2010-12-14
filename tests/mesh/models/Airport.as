package mesh.models
{
	public dynamic class Airport extends NavigationAid
	{
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
		
		override public function translateFrom(object:Object):void
		{
			super.translateFrom(object);
			
			var data:AirportVO = AirportVO( object );
			icao = data.icao;
		}
		
		override public function translateTo():Object
		{
			var data:AirportVO = super.translateTo() as AirportVO;
			data.icao = icao;
			return data;
		}
	}
}