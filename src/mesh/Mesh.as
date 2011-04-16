package mesh
{
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
	}
}