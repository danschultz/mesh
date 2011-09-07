package mesh.model.store
{
	import mesh.model.Entity;
	
	import mx.collections.ArrayList;
	import mx.collections.IList;

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
			
			if (_query is LocalQuery && _query.entityType != null) {
				result(store.index.findByType(_query.entityType));
			}
		}
		
		/**
		 * @inheritDoc
		 */
		override public function result(data:*):void
		{
			// Assert the data is the right type, and convert the array to a list.
			if (!(data is IList || data is Array)) {
				throw new ArgumentError("Result must be an IList or Array");
			}
			data = data is IList ? data.toArray() : data;
			
			// Replace any elements in the result that exist in the store.
			data = data.map(function(entity:Entity, ...args):Entity
			{
				var storeEntity:Entity = store.index.findByTypeAndID(entity.reflect.clazz, entity.id);
				return storeEntity != null ? storeEntity : entity;
			});
			
			// Add elements to the store if they need to be added.
			for each (var entity:Entity in data) {
				if (!store.index.contains(entity)) {
					entity.synced();
					store.add(entity);
				}
			}
			
			// We're done.
			_result.loaded(new ArrayList(data));
			super.result(_result);
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