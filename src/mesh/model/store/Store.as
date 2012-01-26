package mesh.model.store
{
	import mesh.core.reflection.newInstance;
	import mesh.mesh_internal;
	import mesh.model.Record;
	import mesh.model.source.DataSource;
	
	use namespace mesh_internal;
	
	/**
	 * The <code>Store</code> holds all records belonging to your application.
	 * 
	 * @author Dan Schultz
	 */
	public class Store
	{
		/**
		 * Constructor.
		 * 
		 * @param dataSource The data source.
		 */
		public function Store(dataSource:DataSource)
		{
			_dataSource = dataSource;
		}
		
		/**
		 * Returns a query builder for the given record type.
		 * 
		 * @param recordType The type of record to query.
		 * @return A query builder.
		 */
		public function query(recordType:Class):QueryBuilder
		{
			return new QueryBuilder(this, recordType);
		}
		
		/**
		 * Either creates, or returns an existing record from the store with the given data.
		 * 
		 * @param data The data to assign on the record.
		 * @return A record.
		 */
		public function materialize(data:Data):*
		{
			cache.insert(data);
			
			var record:Record = records.find(data.type).byId(data.id);
			if (record == null) {
				record = newInstance(data.type);
				record.id = data.id;
				records.insert(record);
			}
			
			record.data = data;
			return record;
		}
		
		private var _cache:DataCache;
		/**
		 * @copy DataCache
		 */
		mesh_internal function get cache():DataCache
		{
			if (_cache == null) {
				_cache = new DataCache();
			}
			return _cache;
		}
		
		private var _dataSource:DataSource;
		/**
		 * The store's data source.
		 */
		mesh_internal function get dataSource():DataSource
		{
			return _dataSource;
		}
		
		private var _records:Records;
		/**
		 * @copy Records
		 */
		mesh_internal function get records():Records
		{
			if (_records == null) {
				_records = new Records(this);
			}
			return _records;
		}
	}
}