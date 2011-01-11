package mesh.associations
{
	import mesh.Entity;
	
	public dynamic class HasManyAssociation extends AssociationCollection
	{
		/**
		 * @copy AssociationCollection#AssociationCollection()
		 */
		public function HasManyAssociation(source:Entity, relationship:Relationship)
		{
			super(source, relationship);
		}
		
		/**
		 * @inheritDoc
		 */
		override protected function handleEntitiesAdded(entities:Array):void
		{
			super.handleEntitiesAdded(entities);
			
			for each (var entity:Entity in entities) {
				populateBelongsToAssociation(entity);
			}
		}
	}
}