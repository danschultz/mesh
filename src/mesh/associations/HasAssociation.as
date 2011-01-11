package mesh.associations
{
	import collections.HashSet;
	import collections.ISet;
	
	import mesh.Entity;
	
	import operations.EmptyOperation;
	import operations.Operation;
	
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