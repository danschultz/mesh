package mesh.model.associations
{
	import flash.errors.IllegalOperationError;
	import flash.utils.flash_proxy;
	
	import mesh.Mesh;
	import mesh.model.Entity;
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
					return Mesh.service(definition.target).find(owner[definition.foreignKey]);
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
			return super.object;
		}
		override flash_proxy function set object(value:*):void
		{
			value = (value is HasOneAssociation) ? value.object : value;
			var oldValue:Entity = object;
			
			callbackIfNotNull("beforeRemove", oldValue);
			callbackIfNotNull("beforeAdd", value);
			
			super.object = value;
			
			callbackIfNotNull("afterRemove", oldValue);
			callbackIfNotNull("afterAdd", value);
		}
	}
}