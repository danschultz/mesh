package mesh.model.store
{
	import flash.utils.Dictionary;

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
		 * Returns the cached result for the given query. If the result hasn't been 
		 * cached, then a new result is created.
		 * 
		 * @param query The query to get the results for.
		 * @return The query's result.
		 */
		internal function results(query:Query):ResultList
		{
			if (!contains(query)) {
				var result:ResultList = new ResultList(query, _store);
				_cache[query] = result;
			}
			return _cache[query];
		}
	}
}