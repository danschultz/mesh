package mesh.model.store
{
	import collections.HashMap;

	/**
	 * A index of arbitrary store data.
	 * 
	 * @author Dan Schultz
	 */
	public class Index
	{
		private var _index:HashMap = new HashMap();
		
		/**
		 * Constructor.
		 */
		public function Index()
		{
			
		}
		
		/**
		 * Returns data that mapped to the given index.
		 * 
		 * @param id The index to grab.
		 * @return The mapped data.
		 */
		public function byId(id:Object):*
		{
			return _index.grab(id);
		}
		
		internal function insert(id:Object, data:Object):void
		{
			_index.put(id, data);
		}
	}
}