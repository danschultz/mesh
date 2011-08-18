package mesh.model.query
{
	import flash.utils.Dictionary;
	
	import mesh.model.source.Source;
	import mesh.model.store.Store;
	
	import mx.collections.IList;

	/**
	 * A class that caches the results of each query in the store.
	 * 
	 * @author Dan Schultz
	 */
	public class Queries
	{
		private var _cache:Dictionary = new Dictionary();
		
		private var _store:Store;
		private var _dataSource:Source;
		
		/**
		 * Constructor.
		 * 
		 * @param store The store that owns these queries.
		 * @param dataSource The store's data source.
		 */
		public function Queries(store:Store, dataSource:Source)
		{
			_store = store;
			_dataSource = dataSource;
		}
		
		/**
		 * Checks if the given query has been cached.
		 * 
		 * @param query The query to check.
		 * @return <code>true</code> if the query was found.
		 */
		public function contains(query:Query):Boolean
		{
			return _cache[query] != null;
		}
		
		/**
		 * Called by the data source to load the fetched entities of a query into the result list.
		 * 
		 * @param query The query that was loaded.
		 * @param entities The entities that were fetched.
		 */
		public function loaded(query:Query, entities:IList):void
		{
			if (!contains(query)) {
				throw new ArgumentError("Query '" + query + "' not found in cache."); 
			}
			results(query).loaded(entities);
		}
		
		/**
		 * Returns the cached result for the given query. If the result hasn't been 
		 * cached, then a new result is created.
		 * 
		 * @param query The query to get the results for.
		 * @return The query's result.
		 */
		public function results(query:Query):ResultList
		{
			if (!contains(query)) {
				_cache[query] = new ResultList(query, _dataSource).refresh();
			}
			return _cache[query];
		}
	}
}