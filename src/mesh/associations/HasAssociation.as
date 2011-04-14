package mesh.associations
{
	import flash.utils.flash_proxy;
	
	import mesh.Entity;
	
	use namespace flash_proxy;
	
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
			flash_proxy::object = _persistedTarget;
			
			if (flash_proxy::object != null) {
				flash_proxy::object.revert();
			}
		}
		
		private function targetDestroyed(entity:Entity):void
		{
			_persistedTarget = null;
			flash_proxy::object = null;
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
			return [_persistedTarget, flash_proxy::object].filter(function(entity:Entity, ...args):Boolean
			{
				return entity != null && entity.isDirty;
			});
		}
		
		private var _persistedTarget:*;
		/**
		 * @inheritDoc
		 */
		override flash_proxy function get object():*
		{
			return super.flash_proxy::object;
		}
		override flash_proxy function set object(value:*):void
		{
			if (flash_proxy::object != null) {
				flash_proxy::object.removeObserver("afterDestroy", targetDestroyed);
				flash_proxy::object.removeObserver("afterSave", targetSaved);
			}
			
			super.flash_proxy::object = value;
			
			if (flash_proxy::object != null) {
				flash_proxy::object.revive();
				
				flash_proxy::object.addObserver("afterSave", targetSaved);
				flash_proxy::object.addObserver("afterDestroy", targetDestroyed);
			}
		}
	}
}