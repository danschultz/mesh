package mesh.model.associations
{
	import flash.errors.IllegalOperationError;
	import flash.utils.flash_proxy;
	
	import mesh.model.Entity;
	
	use namespace flash_proxy;
	
	public class HasAssociation extends Association
	{
		/**
		 * @copy AssociationProxy#AssociationProxy()
		 */
		public function HasAssociation(owner:Entity, relationship:HasOneDefinition)
		{
			super(owner, relationship);
		}
		
		private function populateForeignKey(entity:Entity):void
		{
			if (definition.hasForeignKey) {
				if (owner.hasOwnProperty(definition.foreignKey)) {
					owner[definition.foreignKey] = entity.id;
				} else {
					throw new IllegalOperationError("Foreign key '" + definition.foreignKey + "' is not defined on " + entity.reflect.name);
				}
			}
		}
	}
}