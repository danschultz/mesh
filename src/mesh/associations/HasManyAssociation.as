package mesh.associations
{
	import flash.utils.IDataInput;
	import flash.utils.IDataOutput;
	import flash.utils.IExternalizable;
	
	import mesh.Entity;
	
	[RemoteClass(alias="mesh.associations.HasManyAssociation")]
	public dynamic class HasManyAssociation extends AssociationCollection implements IExternalizable
	{
		public function HasManyAssociation(source:Entity = null, relationship:Relationship = null)
		{
			super(source, relationship);
		}
		
		/**
		 * @private
		 */
		override public function readExternal(input:IDataInput):void
		{
			target = input.readObject() as Array;
		}
		
		/**
		 *  @private
		 */
		override public function writeExternal(output:IDataOutput):void
		{
			output.writeObject(toArray());
		}
	}
}