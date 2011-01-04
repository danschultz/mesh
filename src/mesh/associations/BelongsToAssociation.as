package mesh.associations
{
	import mesh.Entity;
	
	public class BelongsToAssociation extends AssociationProxy
	{
		public function BelongsToAssociation(owner:Entity, relationship:Relationship)
		{
			super(owner, relationship);
		}
		
		/**
		 * @inheritDoc
		 */
		override public function loaded():void
		{
			_oldTarget = target;
		}
		
		/**
		 * @inheritDoc
		 */
		override public function get isDirty():Boolean
		{
			if (_oldTarget != null && target != null) {
				return !_oldTarget.equals(target);
			}
			return _oldTarget != target;
		}
		
		private var _oldTarget:*;
		override public function get target():*
		{
			return super.target;
		}
		override public function set target(value:*):void
		{
			super.target = value;
		}
	}
}