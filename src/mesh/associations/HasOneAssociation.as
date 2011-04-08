package mesh.associations
{
	import mesh.Entity;
	
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