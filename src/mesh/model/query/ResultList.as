package mesh.model.query
{
	import mesh.core.List;
	import mesh.model.source.Source;
	
	import mx.collections.IList;
	
	/**
	 * The <code>ResultList</code> is a list of entities after an execution of a 
	 * query.
	 * 
	 * @author Dan Schultz
	 */
	public class ResultList extends List
	{
		private var _query:Query;
		private var _source:Source;
		
		/**
		 * Constructor.
		 * 
		 * @param query The query bound to this result.
		 * @param store The source that will fetch the query. 
		 */
		public function ResultList(query:Query, source:Source)
		{
			super();
			_query = query;
			_source = source;
		}
		
		/**
		 * Used internally by Mesh to load the fetched data from a data source into the result list.
		 * 
		 * @param list The list of data to populate the result with.
		 */
		internal function loaded(results:IList):void
		{
			list = results;
		}
		
		/**
		 * Refreshes the results of this list based on the list's query.
		 * 
		 * @return This list.
		 */
		public function refresh():ResultList
		{
			_source.fetch(_query);
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