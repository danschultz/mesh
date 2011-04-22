package mesh.model.associations
{
	import flash.errors.IllegalOperationError;
	import flash.utils.flash_proxy;
	
	import mesh.Mesh;
	import mesh.model.Entity;
	import mesh.services.Request;
	
	use namespace flash_proxy;
	
	public dynamic class HasManyAssociation extends AssociationCollection
	{
		/**
		 * @copy AssociationCollection#AssociationCollection()
		 */
		public function HasManyAssociation(source:Entity, definition:HasManyDefinition)
		{
			super(source, definition);
		}
		
		/**
		 * @inheritDoc
		 */
		override protected function createLoadRequest():Request
		{
			if (Mesh.services.hasService(definition.target)) {
				return Mesh.service(definition.target).belongingTo(owner);
			}
			throw new IllegalOperationError("Cannot load " + this + " with undefined service undefined for " + definition);
		}
	}
}