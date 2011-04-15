package mesh.associations
{
	import mesh.Entity;
	
	public dynamic class HasManyAssociation extends AssociationCollection
	{
		/**
		 * @copy AssociationCollection#AssociationCollection()
		 */
		public function HasManyAssociation(source:Entity, relationship:HasManyDefinition)
		{
			super(source, relationship);
		}
	}
}