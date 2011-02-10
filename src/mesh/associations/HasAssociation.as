package mesh.associations
{
	import mesh.Entity;
	
	public class HasAssociation extends AssociationProxy
	{
		/**
		 * @copy AssociationProxy#AssociationProxy()
		 */
		public function HasAssociation(owner:Entity, relationship:Relationship)
		{
			super(owner, relationship);
		}
	}
}