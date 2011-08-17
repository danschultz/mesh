package mesh.model.associations
{
	import flash.utils.flash_proxy;
	
	import mesh.model.Entity;
	
	use namespace flash_proxy;
	
	public dynamic class HasManyAssociation extends AssociationCollection
	{
		/**
		 * @copy AssociationCollection#AssociationCollection()
		 */
		public function HasManyAssociation(source:Entity, definition:HasManyDefinition)
		{
			super(source, definition);
		}
	}
}