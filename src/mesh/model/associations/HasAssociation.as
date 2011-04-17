package mesh.model.associations
{
	import flash.errors.IllegalOperationError;
	import flash.utils.flash_proxy;
	
	import mesh.model.Entity;
	import mesh.services.Request;
	
	use namespace flash_proxy;
	
	public class HasAssociation extends Association
	{
		/**
		 * @copy AssociationProxy#AssociationProxy()
		 */
		public function HasAssociation(owner:Entity, relationship:HasOneDefinition)
		{
			super(owner, relationship);
			beforeAdd(populateForeignKey);
		}
		
		private function populateForeignKey(entity:Entity):void
		{
			if (definition.hasForeignKey) {
				if (owner.hasOwnProperty(definition.foreignKey)) {
					owner[definition.foreignKey] = entity.id;
				} else {
					throw new IllegalOperationError("Foreign key '" + definition.foreignKey + "' is not defined on " + entity.reflect.name);
				}
			}
		}
		
		/**
		 * @inheritDoc
		 */
		override public function revert():void
		{
			object = _persistedTarget;
			
			if (object != null) {
				object.revert();
			}
		}
		
		private function targetDestroyed(entity:Entity):void
		{
			_persistedTarget = null;
			object = null;
		}
		
		private function targetSaved(entity:Entity):void
		{
			_persistedTarget = entity;
		}
		
		/**
		 * @inheritDoc
		 */
		override public function save():Request
		{
			return object.save();
		}
		
		/**
		 * @inheritDoc
		 */
		override protected function get dirtyEntities():Array
		{
			return [_persistedTarget, object].filter(function(entity:Entity, ...args):Boolean
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
			return super.object;
		}
		override flash_proxy function set object(value:*):void
		{
			if (object != null) {
				object.removeObserver("afterDestroy", targetDestroyed);
				object.removeObserver("afterSave", targetSaved);
			}
			
			super.object = value;
			
			if (object != null) {
				object.revive();
				
				object.addObserver("afterSave", targetSaved);
				object.addObserver("afterSave", populateForeignKey);
				object.addObserver("afterDestroy", targetDestroyed);
			}
		}
	}
}