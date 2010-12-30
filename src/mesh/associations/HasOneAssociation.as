package mesh.associations
{
	import flash.utils.IExternalizable;
	
	import mesh.Entity;
	
	[RemoteClass(alias="mesh.associations.HasOneAssociation")]
	public dynamic class HasOneAssociation extends AssociationProxy implements IExternalizable
	{
		public function HasOneAssociation(owner:Entity, relationship:Relationship)
		{
			super(owner, relationship);
		}
		
		/**
		 * @inheritDoc
		 */
		override public function fromVO(vo:Object, options:Object = null):void
		{
			target = createEntityFromVOMapping(vo, options);
		}
		
		/**
		 * @inheritDoc
		 */
		override public function revert():void
		{
			if (target != null) {
				target.revert();
			}
		}
	}
}