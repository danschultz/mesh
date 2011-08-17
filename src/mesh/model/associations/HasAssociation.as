package mesh.model.associations
{
	import flash.errors.IllegalOperationError;
	import flash.utils.IDataInput;
	import flash.utils.IDataOutput;
	import flash.utils.IExternalizable;
	import flash.utils.flash_proxy;
	
	import mesh.model.Entity;
	
	use namespace flash_proxy;
	
	[RemoteClass(alias="mesh.model.associations.HasAssociation")]
	
	public class HasAssociation extends Association implements IExternalizable
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
		
		/**
		 * @inheritDoc
		 */
		public function readExternal(input:IDataInput):void
		{
			object = input.readObject();
		}
		
		/**
		 * @inheritDoc
		 */
		public function writeExternal(output:IDataOutput):void
		{
			output.writeObject(object);
		}
	}
}