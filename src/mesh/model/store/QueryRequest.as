package mesh.model.store
{
	/**
	 * A request that wraps the loading of a query.
	 * 
	 * @author Dan Schultz
	 */
	public class QueryRequest extends AsyncRequest
	{
		private var _query:Query;
		private var _result:ResultList;
		
		/**
		 * Constructor.
		 * 
		 * @param store The store that created this request.
		 * @param query The query to load.
		 * @param options An options hash.
		 */
		public function QueryRequest(store:Store, query:Query, options:Object = null)
		{
			_query = query;
			_result = store.query.results(query);
			super(store, _result, options);
		}
		
		/**
		 * @inheritDoc
		 */
		override protected function executeRequest():void
		{
			store.dataSource.fetch(this, _query);
		}
		
		/**
		 * @inheritDoc
		 */
		override protected function get isLoaded():Boolean
		{
			return _result.isLoaded;
		}
	}
}