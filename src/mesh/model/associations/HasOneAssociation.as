package mesh.model.associations
{
	import mesh.model.Entity;
	
	public class HasOneAssociation extends HasAssociation
	{
		/**
		 * @copy HasAssociation#HasAssociation()
		 */
		public function HasOneAssociation(owner:Entity, property:String, options:Object = null)
		{
			super(owner, property, options);
		}
	}
}