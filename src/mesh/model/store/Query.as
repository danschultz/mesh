package mesh.model.store
{
	import mesh.model.source.DataSource;

	/**
	 * A query contains the information necessary to fetch data from a store or data source.
	 * 
	 * @author Dan Schultz
	 */
	public class Query
	{
		private var _store:Store;
		
		/**
		 * Constructor.
		 * 
		 * @param store The store to query.
		 * @param dataSource The data source to query.
		 * @param recordType The type of records to query.
		 */
		public function Query(store:Store, dataSource:DataSource, recordType:Class)
		{
			_store = store;
			_dataSource = dataSource;
			_recordType = recordType;
		}
		
		public function createRequest():DataSourceRequest
		{
			
		}
		
		public function find():*
		{
			
		}
		
		private var _dataSource:DataSource;
		/**
		 * The data source to query.
		 */
		protected function get dataSource():DataSource
		{
			return _dataSource;
		}
		
		private var _recordType:Class;
		/**
		 * The type of records to query.
		 */
		public function get recordType():Class
		{
			return _recordType;
		}
	}
}