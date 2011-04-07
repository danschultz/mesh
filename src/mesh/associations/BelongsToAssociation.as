package mesh.associations
{
	import mesh.Entity;
	import mesh.Query;
	
	import operations.Operation;
	import operations.ResultOperationEvent;
	
	public class BelongsToAssociation extends HasAssociation
	{
		/**
		 * @copy AssociationProxy#AssociationProxy()
		 */
		public function BelongsToAssociation(owner:Entity, relationship:AssociationDefinition)
		{
			super(owner, relationship);
		}
		
		/**
		 * @private
		 */
		override protected function createLoadOperation():Operation
		{
			var operation:Operation = Query.entity(definition.target).find(owner[BelongsToRelationship( definition ).foreignKey]);
			operation.addEventListener(ResultOperationEvent.RESULT, function(event:ResultOperationEvent):void
			{
				event.data = event.data[0];
			});
			return operation;
		}
	}
}