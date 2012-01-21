package mesh.model.store
{
	import flash.utils.Dictionary;
	
	import mesh.mesh_internal;
	
	use namespace mesh_internal;
	
	/**
	 * The data cache stores data that was retrieved through a data source.
	 * 
	 * @author Dan Schultz
	 */
	public class DataCache
	{
		private var _indexes:Dictionary = new Dictionary();
		
		/**
		 * Constructor.
		 */
		public function DataCache()
		{
			
		}
		
		/**
		 * Finds the index of data for a record type.
		 * 
		 * @param type The type of record.
		 * @return An index of data.
		 */
		public function find(type:Class):Index
		{
			return index(type);
		}
		
		private function index(type:Class):Index
		{
			if (_indexes[type] == null) {
				_indexes[type] = new Index(type);
			}
			return _indexes[type];
		}
		
		/**
		 * Inserts data into the cache.
		 * 
		 * @param data The data to insert.
		 */
		public function insert(data:Data):void
		{
			index(data.type).insert(data.id, data);
		}
	}
}