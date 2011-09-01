package mesh.model.store
{
	import mesh.model.Entity;
	
	import mx.collections.ArrayList;

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
			data = data is Array ? new ArrayList(data) : data;
			store.add.apply(null, data.toArray().filter(function(entity:Entity, ...args):Boolean
			{
				return !store.index.contains(entity);
			}));
			_result.loaded(data);
			super.result(data);
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