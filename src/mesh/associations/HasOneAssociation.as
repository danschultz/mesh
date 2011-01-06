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
			
			_persistedTarget = target;
			
			if (target != null) {
				target.found();
			}
		}
		
		private function replaceKey():void
		{
			owner[(relationship as HasOneRelationship).foreignKey] = target != null ? target.id : undefined;
		}
		
		/**
		 * @inheritDoc
		 */
		override public function revert():void
		{
			target = _persistedTarget;
			
			if (target != null) {
				target.revert();
			}
		}
		
		/**
		 * @inheritDoc
		 */
		override public function get isDirty():Boolean
		{
			return _persistedTarget != null && target != null ? !_persistedTarget.equals(target) : _persistedTarget != target;
		}
		
		private var _persistedTarget:*;
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
			
			replaceKey();
		}
	}
}