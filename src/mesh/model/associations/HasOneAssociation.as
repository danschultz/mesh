package mesh.model.associations
{
	import flash.utils.flash_proxy;
	
	import mesh.model.Entity;
	
	use namespace flash_proxy;
	
	[RemoteClass(alias="mesh.model.associations.HasOneAssociation")]
	
	public dynamic class HasOneAssociation extends HasAssociation
	{
		/**
		 * @copy HasAssociation#HasAssociation()
		 */
		public function HasOneAssociation(owner:Entity, definition:HasOneDefinition)
		{
			super(owner, definition);
		}
	}
}