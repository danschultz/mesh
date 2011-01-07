package mesh.associations
{
	import mesh.Entity;
	
	public class BelongsToAssociation extends HasOneAssociation
	{
		/**
		 * @copy AssociationProxy#AssociationProxy()
		 */
		public function BelongsToAssociation(owner:Entity, relationship:Relationship)
		{
			super(owner, relationship);
		}
		
		private function replaceKey():void
		{
			owner[(relationship as HasOneRelationship).foreignKey] = target != null ? target.id : undefined;
		}
	}
}