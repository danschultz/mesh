package mesh.model.store
{
	import flash.events.EventDispatcher;

	/**
	 * A query contains the information necessary to fetch data from a store or data source.
	 * 
	 * @author Dan Schultz
	 */
	public class Query extends EventDispatcher
	{
		/**
		 * Constructor.
		 * 
		 * @param store The store to query.
		 * @param dataSource The data source to query.
		 * @param recordType The type of records to query.
		 */
		public function Query(store:Store, recordType:Class)
		{
			_store = store;
			_recordType = recordType;
		}
		
		/**
		 * Executes the query.
		 */
		public function execute():*
		{
			
		}
		
		private var _recordType:Class;
		/**
		 * The type of records to query.
		 */
		public function get recordType():Class
		{
			return _recordType;
		}
		
		private var _store:Store;
		/**
		 * The store that will be queried.
		 */
		protected function get store():Store
		{
			return _store;
		}
	}
}