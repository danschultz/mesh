package mesh.associations
{
	import collections.HashSet;
	import collections.ISet;
	
	import functions.closure;
	
	import mesh.Entity;
	
	public dynamic class HasOneAssociation extends HasAssociation
	{
		/**
		 * @copy HasAssociation#HasAssociation()
		 */
		public function HasOneAssociation(owner:Entity, relationship:Relationship)
		{
			super(owner, relationship);
		}
		
		/**
		 * @inheritDoc
		 */
		override public function findEntitiesToSave():ISet
		{
			var entities:HashSet = new HashSet();
			
			if (_persistedTarget != null && _persistedTarget.isMarkedForRemoval) {
				entities.add(_persistedTarget);
			}
			
			if (target != null && target.isDirty) {
				entities.add(target);
			}
			
			return entities;
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
		
		private function replace(newTarget:Entity):void
		{
			if (newTarget != null) {
				newTarget.revive();
			}
			
			if (_persistedTarget != null && !_persistedTarget.equals(newTarget)) {
				_persistedTarget.markForRemoval();
			}
			
			if (newTarget != null) {
				populateBelongsToAssociation(newTarget);
			}
		}
		
		/**
		 * @inheritDoc
		 */
		override protected function get dirtyEntities():Array
		{
			return [_persistedTarget, target].filter(closure(function(entity:Entity):Boolean
			{
				return entity != null && entity.isDirty;
			}));
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
			replace(value);
			super.target = value;
		}
	}
}