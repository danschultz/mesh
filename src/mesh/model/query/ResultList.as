package mesh.model.query
{
	import mesh.core.List;
	import mesh.model.store.Store;
	
	/**
	 * The <code>ResultList</code> is a list of entities after an execution of a 
	 * query.
	 * 
	 * @author Dan Schultz
	 */
	public class ResultList extends List
	{
		private var _query:Query;
		private var _store:Store;
		
		/**
		 * Constructor.
		 * 
		 * @param query The query bound to this result.
		 * @param store The store that the query is executing against. 
		 */
		public function ResultList(query:Query, store:Store)
		{
			super();
			_query = query;
			_store = store;
		}
		
		/**
		 * Refreshes the results of this list based on the list's query.
		 * 
		 * @return This list.
		 */
		public function refresh():ResultList
		{
			return this;
		}
		
		/**
		 * @inheritDoc
		 */
		override public function get source():Array
		{
			return super.source.concat();
		}
		override public function set source(value:Array):void
		{
			// Don't allow clients to set the source.
		}
	}
}