package mesh.associations
{
	import mesh.Entity;
	
	public class BelongsToAssociation extends AssociationProxy
	{
		/**
		 * @copy AssociationProxy#AssociationProxy()
		 */
		public function BelongsToAssociation(owner:Entity, relationship:Relationship)
		{
			super(owner, relationship);
		}
		
		/**
		 * @inheritDoc
		 */
		override public function loaded():void
		{
			super.loaded();
			
			if (target != null) {
				target.found();
			}
		}
		
		private function replaceKey():void
		{
			owner[(relationship as BelongsToRelationship).foreignKey] = target != null ? target.id : undefined;
		}
		
		/**
		 * @inheritDoc
		 */
		override public function get isDirty():Boolean
		{
			var foreignKey:* = (relationship as BelongsToRelationship).foreignKey;
			if (target == null) {
				return owner[foreignKey] != null;
			}
			return target.id != owner[foreignKey];
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
			if (value != null) {
				value.revive();
			}
			
			super.target = value;
			
			replaceKey();
		}
	}
}