package mesh.associations
{
	import mesh.Entity;
	import mesh.Query;
	import mesh.core.inflection.camelize;
	import mesh.core.reflection.className;
	
	import mesh.operations.Operation;
	
	public dynamic class HasManyAssociation extends AssociationCollection
	{
		/**
		 * @copy AssociationCollection#AssociationCollection()
		 */
		public function HasManyAssociation(source:Entity, relationship:AssociationDefinition)
		{
			super(source, relationship);
		}
		
		/**
		 * @private
		 */
		override protected function createLoadOperation():Operation
		{
			var options:Object = {};
			options[camelize(className(definition.owner), false)] = owner;
			
			return Query.entity(definition.target).where(options);
		}
	}
}