package mesh.model.store
{
	import flash.utils.Dictionary;
	
	import mesh.model.Record;

	/**
	 * The index of records belonging to the store.
	 * 
	 * @author Dan Schultz
	 */
	public class Records
	{
		private var _indexes:Dictionary = new Dictionary();
		private var _store:Store;
		
		/**
		 * Constructor.
		 */
		public function Records(store:Store)
		{
			_store = store;
		}
		
		/**
		 * Finds the record index for a given record type.
		 * 
		 * @param type The type of record.
		 * @return An index of records.
		 */
		public function find(type:Class):Index
		{
			return index(type);
		}
		
		private function index(type:Class):Index
		{
			if (_indexes[type] == null) {
				_indexes[type] = new Index();
			}
			return _indexes[type];
		}
		
		/**
		 * Inserts records into the cache.
		 * 
		 * @param record The record to insert.
		 */
		public function insert(record:Record):void
		{
			record.store = _store;
			index(record.reflect.clazz).insert(record.id, record);
		}
	}
}