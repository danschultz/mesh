package mesh.associations
{
	import mesh.Entity;
	import mesh.Query;
	import mesh.core.inflection.camelize;
	import mesh.core.reflection.className;
	
	import operations.Operation;
	
	public dynamic class HasManyAssociation extends AssociationCollection
	{
		/**
		 * @copy AssociationCollection#AssociationCollection()
		 */
		public function HasManyAssociation(source:Entity, relationship:Relationship)
		{
			super(source, relationship);
		}
		
		/**
		 * @private
		 */
		override protected function createLoadOperation():Operation
		{
			var options:Object = {};
			options[camelize(className(relationship.owner), false)] = owner;
			options.method = relationship.method;
			return Query.entity(relationship.target).where(options);
		}
		
		/**
		 * @inheritDoc
		 */
		override protected function handleEntitiesAdded(entities:Array):void
		{
			super.handleEntitiesAdded(entities);
			
			for each (var entity:Entity in entities) {
				populateBelongsToAssociation(entity);
			}
		}
	}
}