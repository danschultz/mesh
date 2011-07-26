package mesh
{
	import mesh.model.EntityStore;
	import mesh.services.Service;
	import mesh.services.Services;

	/**
	 * A class that defines the globals used by Mesh.
	 * 
	 * @author Dan Schultz
	 */
	public class Mesh
	{
		/**
		 * The repository of services for the application.
		 */
		public static var services:Services = new Services();
		
		/**
		 * Returns the service that is mapped to the given entity type.
		 * 
		 * @param type The entity to retrieve the service for.
		 * @return The entity's service.
		 */
		public static function service(type:Class):Service
		{
			return services.serviceFor(type);
		}
		
		/**
		 * The repository of all <code>Entity</code>s in the application.
		 */
		public static var store:EntityStore;
	}
}