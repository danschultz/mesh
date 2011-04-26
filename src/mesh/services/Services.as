package mesh.services
{
	import collections.HashMap;
	
	import mesh.core.reflection.Type;
	import mesh.core.reflection.reflect;
	import mesh.model.Entity;

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
			var type:Type = reflect(entity);
			while (type.clazz != Entity) {
				if (hasService(type.clazz)) {
					return _entityToService.grab(type.clazz);
				}
				type = type.parent;
			}
			throw new ArgumentError("Service not found for " + Type.reflect(entity).name);
		}
	}
}