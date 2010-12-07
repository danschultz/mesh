package mesh
{
	public class Translation
	{
		public function Translation(entityType:Class, translationObjectType:Class, options:Object)
		{
			_entityType = entityType;
			_translationObjectType = translationObjectType;
			_options = options;
		}
		
		private var _entityType:Class;
		public function get entityType():Class
		{
			return _entityType;
		}
		
		private var _translationObjectType:Class;
		public function get translationObjectType():Class
		{
			return _translationObjectType;
		}
		
		private var _options:Object;
		public function get options():Object
		{
			return _options;
		}
	}
}