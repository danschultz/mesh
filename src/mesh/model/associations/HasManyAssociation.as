package mesh.model.associations
{
	import flash.utils.IExternalizable;
	import flash.utils.flash_proxy;
	
	import mesh.model.Entity;
	
	use namespace flash_proxy;
	
	[RemoteClass(alias="mesh.model.associations.HasManyAssociation")]
	
	public dynamic class HasManyAssociation extends AssociationCollection implements IExternalizable
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