package mesh.associations
{
	import flash.utils.flash_proxy;
	
	import mesh.Entity;
	
	use namespace flash_proxy;
	
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
		override flash_proxy function get object():*
		{
			return super.flash_proxy::object;
		}
		override flash_proxy function set object(value:*):void
		{
			value = (value is HasOneAssociation) ? value.flash_proxy::object : value;
			var oldValue:Entity = flash_proxy::object;
			
			callbackIfNotNull("beforeRemove", oldValue);
			callbackIfNotNull("beforeAdd", value);
			
			super.flash_proxy::object = value;
			
			callbackIfNotNull("afterRemove", oldValue);
			callbackIfNotNull("afterAdd", value);
		}
	}
}