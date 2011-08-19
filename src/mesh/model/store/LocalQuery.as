package mesh.model.store
{
	/**
	 * The <code>LocalQuery</code> class defines a search against the data store. This type
	 * of query will refresh its results whenever the an entity is added or removed from the
	 * store. When executed, this query is still passed to the data source's fetch method. 
	 * This gives an opportunity for the data source to load more results into the store.
	 * 
	 * @author Dan Schultz
	 */
	public class LocalQuery extends Query
	{
		/**
		 * @copy Query#Query()
		 */
		public function LocalQuery()
		{
			super();
		}
	}
}