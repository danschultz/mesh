package mesh.model.store
{
	import flash.events.EventDispatcher;
	
	import mesh.model.source.DataSource;

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
		 * @param dataSource The data source to load records from.
		 * @param records The records to query.
		 * @param recordType The type of records to query.
		 */
		public function Query(dataSource:DataSource, records:Records, recordType:Class)
		{
			_dataSource = dataSource;
			_records = records;
			_recordType = recordType;
		}
		
		/**
		 * Executes the query.
		 */
		public function execute():*
		{
			
		}
		
		private var _dataSource:DataSource;
		/**
		 * The data source to load records from.
		 */
		protected function get dataSource():DataSource
		{
			return _dataSource;
		}
		
		private var _recordType:Class;
		/**
		 * The type of records to query.
		 */
		protected function get recordType():Class
		{
			return _recordType;
		}
		
		private var _records:Records;
		/**
		 * The records to query.
		 */
		protected function get records():Records
		{
			return _records;
		}
	}
}