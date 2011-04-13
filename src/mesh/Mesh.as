package mesh
{
	/**
	 * A class that defines the globals used by Mesh.
	 * 
	 * @author Dan Schultz
	 */
	public class Mesh
	{
		/**
		 * The delay, in milliseconds, between when an operation is created and when it's executed.
		 * This delay lets clients add event listeners to operations before they're executed. Otherwise,
		 * some operations might execute and finish before the event listeners are added.
		 */
		public static const DELAY:int = 50;
		
		//public static var services:Services = new Services();
	}
}