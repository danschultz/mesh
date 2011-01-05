package mesh.associations
{
	import mesh.Entity;
	
	public dynamic class HasOneAssociation extends AssociationProxy
	{
		/**
		 * @copy AssociationProxy#AssociationProxy()
		 */
		public function HasOneAssociation(owner:Entity, relationship:Relationship)
		{
			super(owner, relationship);
		}
		
		/**
		 * @inheritDoc
		 */
		override public function fromVO(vo:Object, options:Object = null):void
		{
			target = createEntityFromVOMapping(vo, options);
		}
		
		/**
		 * @inheritDoc
		 */
		override public function loaded():void
		{
			super.loaded();
			
			if (target != null) {
				target.found();
			}
		}
		
		/**
		 * @inheritDoc
		 */
		override public function revert():void
		{
			if (target != null) {
				target.revert();
			}
		}
		
		/**
		 * @inheritDoc
		 */
		override public function get isDirty():Boolean
		{
			return target != null && target.isDirty;
		}
		
		/**
		 * @inheritDoc
		 */
		override public function get target():*
		{
			return super.target;
		}
		override public function set target(value:*):void
		{
			if (value != null) {
				value.revive();
			}
			
			super.target = value;
		}
	}
}