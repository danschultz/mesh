package mesh.services
{
	import collections.HashMap;

	public class Services
	{
		private var _services:HashMap = new HashMap();
		
		/**
		 * Constructor.
		 */
		public function Services()
		{
			
		}
		
		public function instanceOf(service:Class):Service
		{
			if (!_services.containsKey(service)) {
				_services.put(service, new service());
			}
			return _services.grab(service);
		}
	}
}