package mesh.model.associations
{
	import mesh.model.Entity;
	
	public class HasOneAssociation extends HasAssociation
	{
		/**
		 * @copy HasAssociation#HasAssociation()
		 */
		public function HasOneAssociation(owner:Entity, options:Object = null)
		{
			super(owner, options);
		}
		
		/**
		 * @inheritDoc
		 */
		override public function set object(value:*):void
		{
			if (object != null) unassociate(object);
			super.object = value;
			if (object != null) associate(object);
		}
	}
}