package mesh.model.store
{
	import flash.utils.Dictionary;
	
	import mesh.core.reflection.newInstance;
	import mesh.mesh_internal;
	import mesh.model.Record;
	import mesh.model.source.DataSource;
	
	use namespace mesh_internal;
	
	/**
	 * The index of records belonging to the store.
	 * 
	 * @author Dan Schultz
	 */
	public class Records
	{
		private var _indexes:Dictionary = new Dictionary();
		private var _store:Store;
		private var _cache:DataCache;
		private var _dataSource:DataSource;
		
		/**
		 * Constructor.
		 */
		public function Records(store:Store, dataSource:DataSource, cache:DataCache)
		{
			_store = store;
			_dataSource = dataSource;
			_cache = cache;
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
		
		/**
		 * Either creates, or returns an existing record from the store with the given data.
		 * 
		 * @param data The data to assign on the record.
		 * @return A record.
		 */
		public function materialize(data:Data):*
		{
			_cache.insert(data);
			
			var record:Record = find(data.type).byId(data.id);
			if (record == null) {
				record = newInstance(data.type);
				record.id = data.id;
				insert(record);
			}
			
			record.data = data;
			return record;
		}
	}
}