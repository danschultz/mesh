package mesh
{
	import collections.HashSet;
	
	import flash.events.EventDispatcher;
	
	public dynamic class Repository extends EventDispatcher
	{
		private var _entities:HashSet = new HashSet();
		private var _actions:Array = [];
		
		public function Repository()
		{
			super();
		}
		
		public function commit():void
		{
			
		}
		
		final public function remove(entity:Entity):void
		{
			_entities.remove(entity);
		}
		
		public function retrieve():void
		{
			
		}
	}
}