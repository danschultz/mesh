package mesh.model.store
{
	import mesh.mesh_internal;
	import mesh.model.source.DataSource;
	
	use namespace mesh_internal;
	
	/**
	 * The <code>Store</code> holds all records belonging to your application.
	 * 
	 * @author Dan Schultz
	 */
	public class Store
	{
		private var _dataSource:DataSource;
		
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
		 * Generates a new query builder for a record type.
		 * 
		 * @param recordType The type of record to query.
		 * @return A new query builder.
		 */
		public function query(recordType:Class):QueryBuilder
		{
			return new QueryBuilder(this, _dataSource, recordType);
		}
		
		private var _cache:DataCache;
		/**
		 * @copy DataCache
		 */
		public function get cache():DataCache
		{
			if (_cache == null) {
				_cache = new DataCache();
			}
			return _cache;
		}
	}
}