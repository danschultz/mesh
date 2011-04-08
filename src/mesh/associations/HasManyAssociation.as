package mesh.associations
{
	import mesh.Entity;
	
	public dynamic class HasManyAssociation extends AssociationCollection
	{
		/**
		 * @copy AssociationCollection#AssociationCollection()
		 */
		public function HasManyAssociation(source:Entity, relationship:AssociationDefinition)
		{
			super(source, relationship);
		}
	}
}