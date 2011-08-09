package mesh.model.query
{
	import collections.HashMap;
	
	import mesh.model.Store;

	/**
	 * A class that caches the results of each query in the store.
	 * 
	 * @author Dan Schultz
	 */
	public class Queries
	{
		private var _store:Store;
		private var _cache:HashMap = new HashMap();
		
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
		 * Returns the cached result for the given query. If the result hasn't been 
		 * cached, then a new result is created.
		 * 
		 * @param query The query to get the results for.
		 * @return The query's result.
		 */
		public function result(query:Query):ResultList
		{
			if (!isCached(query)) {
				_cache.put(query, new ResultList(query, _store).refresh());
			}
			return _cache.grab(query);
		}
		
		private function isCached(query:Query):Boolean
		{
			return _cache.containsKey(query);
		}
	}
}