package mesh.model.associations
{
	import mesh.model.Entity;
	import mesh.model.store.Query;
	
	public class AssociationCollection extends Association
	{
		/**
		 * @copy AssociationProxy#AssociationProxy()
		 */
		public function AssociationCollection(source:Entity, query:Query, options:Object = null)
		{
			super(source, query, options);
		}
	}
}