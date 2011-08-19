package mesh.model.query
{
	import mesh.model.Entity;

	/**
	 * The <code>Query</code> class lets you define a search to return a set
	 * of entities from a data store.
	 * 
	 * @author Dan Schultz
	 */
	public class Query
	{
		/**
		 * The default language to use when parsing a query string. Your application can 
		 * define its own language.
		 */
		public static var defaultLanguage:Object;
		
		private var _subject:Class;
		private var _conditions:Array = [];
		private var _comparators:Array = [];
		
		/**
		 * Constructor.
		 */
		public function Query()
		{
			
		}
		
		/**
		 * Returns the sort order for two entities based on the sort defined
		 * in this query.
		 * 
		 * @param entity1 The entity to compare with <code>entity2</code>
		 * @param entity2 The entity to compare with <code>entity1</code>
		 * @return -1 if <code>entity1</code> &lt; <code>entity2</code>, +1 if 
		 * 	<code>entity1</code> &gt; <code>entity2</code>, 0 if equal
		 */
		public function compare(entity1:Entity, entity2:Entity):int
		{
			return 0;
		}
		
		/**
		 * Checks if this query would contain the given entity based on the
		 * query's conditions.
		 * 
		 * @param entity The entity to check.
		 * @return <code>true</code> if the query contains the entity.
		 */
		public function contains(entity:Entity):Boolean
		{
			return false;
		}
		
		/**
		 * Checks if this query is the same as another query.
		 * 
		 * @param query The query to check.
		 * @return <code>true</code> if the queries are the same.
		 */
		public function equals(query:Object):Boolean
		{
			return this === query;
		}
		
		/**
		 * Sets the type of entity that the query runs on.
		 * 
		 * @param entity The type of entity.
		 * @return This instance.
		 */
		public function on(entity:Class):Query
		{
			_subject = entity;
		}
		
		/**
		 * Sets a condition for this query.
		 * 
		 * @param conditions The conditions to filter on.
		 * @return This instance.
		 */
		public function where(...conditions):Query
		{
			_conditions = _conditions.concat(conditions);
			return this;
		}
		
		/**
		 * Sets a sort for this query.
		 * 
		 * @param comparators The comparators.
		 * @return This instance.
		 */
		public function sort(...comparators):Query
		{
			_comparators = _comparators.concat(comparators);
			return this;
		}
	}
}