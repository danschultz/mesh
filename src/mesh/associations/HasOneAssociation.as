package mesh.associations
{
	import mesh.Entity;
	
	public dynamic class HasOneAssociation extends AssociationProxy
	{
		public function HasOneAssociation(owner:Entity, relationship:Relationship)
		{
			super(owner, relationship);
		}
		
		/**
		 * @inheritDoc
		 */
		override public function revert():void
		{
			if (target != null) {
				target.revert();
			}
		}
	}
}