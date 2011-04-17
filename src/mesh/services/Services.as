package mesh.services
{
	import collections.HashMap;
	
	import mesh.core.reflection.Type;

	public class Services
	{
		private var _entityToService:HashMap = new HashMap();
		
		/**
		 * Constructor.
		 */
		public function Services()
		{
			
		}
		
		public function hasService(entity:Class):Boolean
		{
			return _entityToService.containsKey(entity);
		}
		
		public function map(entity:Class, service:Service):void
		{
			_entityToService.put(entity, service);
		}
		
		public function serviceFor(entity:Class):Service
		{
			if (hasService(entity)) {
				return _entityToService.grab(entity);
			}
			throw new ArgumentError("Service not found for " + Type.reflect(entity).name);
		}
	}
}