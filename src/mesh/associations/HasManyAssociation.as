package mesh.associations
{
	import mesh.Entity;
	
	public dynamic class HasManyAssociation extends AssociationCollection
	{
		public function HasManyAssociation(source:Entity, relationship:Relationship)
		{
			super(source, relationship);
		}
	}
}