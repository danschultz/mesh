package mesh.associations
{
	import mesh.Entity;
	
	public class HasAssociation extends Association
	{
		/**
		 * @copy AssociationProxy#AssociationProxy()
		 */
		public function HasAssociation(owner:Entity, relationship:AssociationDefinition)
		{
			super(owner, relationship);
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
		
		private function targetDestroyed(entity:Entity):void
		{
			_persistedTarget = null;
			target = null;
		}
		
		private function targetSaved(entity:Entity):void
		{
			_persistedTarget = entity;
		}
		
		/**
		 * @inheritDoc
		 */
		override protected function get dirtyEntities():Array
		{
			return [_persistedTarget, target].filter(function(entity:Entity, ...args):Boolean
			{
				return entity != null && entity.isDirty;
			});
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
			if (target != null) {
				target.removeCallback(targetDestroyed);
				target.removeCallback(targetSaved);
			}
			
			super.target = value;
			
			if (target != null) {
				target.revive();
				
				target.afterSave(targetSaved);
				target.afterDestroy(targetDestroyed);
			}
		}
	}
}