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
	}
}