package mesh.model.store
{
	import flash.errors.IllegalOperationError;
	
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
	public class RecordCache extends Cache
	{
		private var _store:Store;
		private var _cache:DataCache;
		private var _dataSource:DataSource;
		
		/**
		 * Constructor.
		 */
		public function RecordCache(store:Store, dataSource:DataSource, cache:DataCache)
		{
			_store = store;
			_dataSource = dataSource;
			_cache = cache;
		}
		
		/**
		 * @inheritDoc
		 */
		override public function insert(item:Object):void
		{
			var record:Record = Record( item );
			
			if (record.store == null) {
				record.store = _store;
			}
			
			if (record.store != _store) {
				throw new IllegalOperationError("Cannot insert record into multiple caches.");
			}
			
			super.insert(item);
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
			
			var record:Record = findIndex(data.type).byId(data.id);
			if (record == null) {
				record = newInstance(data.type);
				record.id = data.id;
				insert(record);
			}
			
			data.transferValues(record);
			return record;
		}
	}
}