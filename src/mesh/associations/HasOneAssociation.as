package mesh.associations
{
	import mesh.Entity;
	import mesh.Query;
	import mesh.core.inflection.camelize;
	import mesh.core.reflection.className;
	
	import operations.Operation;
	import operations.ResultOperationEvent;
	
	public dynamic class HasOneAssociation extends HasAssociation
	{
		/**
		 * @copy HasAssociation#HasAssociation()
		 */
		public function HasOneAssociation(owner:Entity, relationship:AssociationDefinition)
		{
			super(owner, relationship);
		}
		
		/**
		 * @private
		 */
		override protected function createLoadOperation():Operation
		{
			var options:Object = {};
			options[camelize(className(definition.owner), false)] = owner;
			
			var operation:Operation = Query.entity(definition.target).where(options);
			operation.addEventListener(ResultOperationEvent.RESULT, function(event:ResultOperationEvent):void
			{
				event.data = event.data[0];
			});
			return operation;
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
			super.target = value;
			
			if (target != null) {
				populateBelongsToAssociation(target);
			}
		}
	}
}