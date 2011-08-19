package mesh.model.store
{
	import flash.utils.Dictionary;
	
	import mesh.model.source.Source;
	
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
		
		/**
		 * Constructor.
		 * 
		 * @param store The store that owns these queries.
		 */
		public function Queries(store:Store)
		{
			_store = store;
		}
		
		/**
		 * Checks if the given query has been cached.
		 * 
		 * @param query The query to check.
		 * @return <code>true</code> if the query was found.
		 */
		internal function contains(query:Query):Boolean
		{
			return _cache[query] != null;
		}
		
		/**
		 * Called by the data source to load the fetched entities of a query into the result list.
		 * 
		 * @param query The query that was loaded.
		 * @param entities The entities that were fetched.
		 */
		public function loaded(query:Query, entities:IList = null):void
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
		internal function results(query:Query):ResultList
		{
			if (!contains(query)) {
				_cache[query] = new ResultList(query, _store).refresh();
			}
			return _cache[query];
		}
	}
}