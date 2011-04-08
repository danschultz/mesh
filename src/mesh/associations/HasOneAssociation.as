package mesh.associations
{
	import mesh.Entity;
	import mesh.Query;
	import mesh.core.inflection.camelize;
	import mesh.core.reflection.className;
	
	import mesh.operations.Operation;
	
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
			return Query.entity(definition.target).where(options);
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
			value = (value is HasOneAssociation) ? value.target : value;
			var oldValue:Entity = target;
			
			callbackIfNotNull("beforeRemove", oldValue);
			callbackIfNotNull("beforeAdd", value);
			
			super.target = value;
			
			callbackIfNotNull("afterRemove", oldValue);
			callbackIfNotNull("afterAdd", value);
		}
	}
}