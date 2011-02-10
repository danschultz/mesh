package mesh.associations
{
	import mesh.Entity;
	import mesh.Query;
	import mesh.core.functions.closure;
	import mesh.core.inflection.camelize;
	import mesh.core.reflection.className;
	
	import operations.Operation;
	import operations.ResultOperationEvent;
	
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
		override public function fromVO(vo:Object, options:Object = null):void
		{
			target = createEntityFromVOMapping(vo, options);
		}
		
		/**
		 * @private
		 */
		override protected function createLoadOperation():Operation
		{
			var options:Object = {};
			options[camelize(className(relationship.owner), false)] = owner;
			
			var operation:Operation = Query.entity(relationship.target).where(options);
			operation.addEventListener(ResultOperationEvent.RESULT, function(event:ResultOperationEvent):void
			{
				event.data = event.data[0];
			});
			return operation;
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
			if (target != null) {
				target.removeCallback(targetDestroyed);
				target.removeCallback(targetSaved);
			}
			
			super.target = value;
			
			if (target != null) {
				target.revive();
				populateBelongsToAssociation(target);
				
				target.afterSave(targetSaved);
				target.afterDestroy(targetDestroyed);
			}
		}
	}
}