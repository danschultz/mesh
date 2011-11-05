package mesh.model.store
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
		
		private var _condition:Function;
		private var _comparator:Function;
		
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
			return _comparator != null ? _comparator(entity1, entity2) : 0;
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
			if (_condition != null) {
				return _condition(entity);
			}
			
			if (entityType != null) {
				return entity.reflect.isA(entityType);
			}
			
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
		 * @param entityType The type of entity.
		 * @return This instance.
		 */
		public function on(entityType:Class):Query
		{
			_entityType = entityType;
			return this;
		}
		
		/**
		 * Sets a condition for this query.
		 * 
		 * @param conditions The conditions to filter on.
		 * @return This instance.
		 */
		public function where(condition:Function):Query
		{
			_condition = condition;
			return this;
		}
		
		/**
		 * Sets a sort for this query.
		 * 
		 * @param comparators The comparators.
		 * @return This instance.
		 */
		public function sort(comparator:Function):Query
		{
			_comparator = comparator;
			return this;
		}
		
		private var _entityType:Class;
		/**
		 * The type of <code>Entity</code> being queried on.
		 */
		public function get entityType():Class
		{
			return _entityType;
		}
		
		private var _parameters:Object;
		/**
		 * The query parameters. The data source can use these parameters when making a
		 * request to the backend.
		 */
		public function get parameters():Object
		{
			return _parameters;
		}
		public function set parameters(value:Object):void
		{
			_parameters = value;
		}
	}
}