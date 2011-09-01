package mesh.model.store
{
	import flash.utils.Dictionary;
	
	import mesh.model.source.SourceFault;
	
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
		 * Called by the data source if it encountered an error during a query.
		 * 
		 * @param query The query that failed.
		 * @param fault The reason of the failure.
		 */
		public function failed(query:Query, fault:SourceFault):void
		{
			results(query).failed(fault);
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
			
			if (entities != null) _store.add.apply(null, entities.toArray());
			
			if (query is RemoteQuery) {
				results(query).loaded(entities);
			}
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
				result.refresh();
			}
			return _cache[query];
		}
	}
}