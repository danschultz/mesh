package mesh.model
{
	/**
	 * The <code>ILoadable</code> interface defines an interface for classes where their
	 * data is loaded externally.
	 * 
	 * @author Dan Schultz
	 */
	public interface ILoadable
	{
		/**
		 * Loads the data for this object, if it has not been loaded yet. If the data has 
		 * already been loaded, then it will not be reloaded. Use <code>refresh()</code> 
		 * to reload the data.
		 * 
		 * @return This instance.
		 */
		function load():*;
		
		/**
		 * Forces a reload of the data for this object. Unlike <code>load()</code>, this 
		 * method will load the data for this object even if it's already been retrieved.
		 * 
		 * @see #load()
		 * @return This instance.
		 */
		function refresh():*;
		
		/**
		 * Checks if the data has been loaded.
		 */
		function get isLoaded():Boolean;
	}
}