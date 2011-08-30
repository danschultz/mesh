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
		
		/**
		 * @inheritDoc
		 */
		override protected function entityDestroyed(entity:Entity):void
		{
			owner[property] = null;
			associate(entity, false);
		}
		
		/**
		 * @inheritDoc
		 */
		override protected function entityRevived(entity:Entity):void
		{
			owner[property] = entity;
		}
		
		/**
		 * @inheritDoc
		 */
		override public function set object(value:*):void
		{
			if (object != null) unassociate(object);
			super.object = value;
			if (object != null) associate(object, true);
		}
	}
}