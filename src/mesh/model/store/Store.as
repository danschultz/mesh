package mesh.model.store
{
	import mesh.core.reflection.newInstance;
	import mesh.mesh_internal;
	import mesh.model.Record;
	import mesh.model.RecordState;
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
			_cache = new DataCache();
			_records = new RecordCache(this, _dataSource, _cache);
		}
		
		/**
		 * Adds a record to the store.
		 * 
		 * @param record The record to add.
		 */
		public function add(record:Record):void
		{
			records.insert(record);
		}
		
		/**
		 * Creates a new unpersisted record in the store.
		 * 
		 * @param recordType The type of record to create.
		 * @return A new record.
		 */
		public function create(recordType:Class):*
		{
			var record:Record = newInstance(recordType);
			record.changeState(RecordState.created());
			records.insert(record);
			return record;
		}
		
		/**
		 * Returns a query builder for the given record type.
		 * 
		 * @param recordType The type of record to query.
		 * @return A query builder.
		 */
		public function query(recordType:Class):QueryBuilder
		{
			return new QueryBuilder(_dataSource, _records, recordType);
		}
		
		/**
		 * @copy Records#materialize()
		 */
		public function materialize(data:Data, state:RecordState = null):*
		{
			return _records.materialize(data, state);
		}
		
		private var _cache:DataCache;
		/**
		 * @private
		 */
		mesh_internal function get cache():DataCache
		{
			return _cache;
		}
		
		private var _dataSource:DataSource;
		/**
		 * @private
		 */
		mesh_internal function get dataSource():DataSource
		{
			return _dataSource;
		}
		
		private var _records:RecordCache;
		/**
		 * @private
		 */
		mesh_internal function get records():RecordCache
		{
			return _records;
		}
	}
}