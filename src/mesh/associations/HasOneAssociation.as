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
		public function HasOneAssociation(owner:Entity, relationship:Relationship)
		{
			super(owner, relationship);
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