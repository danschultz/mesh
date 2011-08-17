package mesh.model.associations
{
	import mesh.model.Entity;
	import mesh.model.query.Query;
	
	public class HasAssociation extends Association
	{
		/**
		 * @copy AssociationProxy#AssociationProxy()
		 */
		public function HasAssociation(owner:Entity, query:Query, options:Object = null)
		{
			super(owner, query, options);
		}
	}
}