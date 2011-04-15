package mesh.model.associations
{
	import flash.errors.IllegalOperationError;
	import flash.utils.flash_proxy;
	
	import mesh.model.Entity;
	import mesh.Mesh;
	import mesh.services.Request;
	
	use namespace flash_proxy;
	
	public dynamic class HasOneAssociation extends HasAssociation
	{
		/**
		 * @copy HasAssociation#HasAssociation()
		 */
		public function HasOneAssociation(owner:Entity, definition:HasOneDefinition)
		{
			super(owner, definition);
		}
		
		/**
		 * @inheritDoc
		 */
		override protected function createLoadRequest():Request
		{
			if (Mesh.services.hasService(definition.target)) {
				if (definition.hasForeignKey) {
					return Mesh.services.serviceFor(definition.target).findOne(definition.foreignKey);
				}
				throw new IllegalOperationError("Cannot load " + this + " with undefined foreign key for " + definition);
			}
			throw new IllegalOperationError("Cannot load " + this + " with undefined service undefined for " + definition);
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