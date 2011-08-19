package mesh.model.store
{
	/**
	 * The <code>RemoteQuery</code> class defines a search that is executed on the server. 
	 * Unlike a local query, the results of the query are not updated when an entity is
	 * added or removed from the store. However, the results will refresh if the entities
	 * in the results change.
	 * 
	 * @author Dan Schultz
	 */
	public class RemoteQuery extends Query
	{
		/**
		 * @copy Query#Query()
		 */
		public function RemoteQuery()
		{
			super();
		}
	}
}