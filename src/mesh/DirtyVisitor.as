package mesh
{
	import flash.utils.Dictionary;
	
	import mesh.associations.AssociationProxy;
	import mesh.associations.BelongsToAssociation;

	public dynamic class DirtyVisitor extends VisitOnceVisitor
	{
		private var _results:Dictionary = new Dictionary();
		
		public function DirtyVisitor()
		{
			super();
		}
		
		override public function enter(association:AssociationProxy):Boolean
		{
			return !(association is BelongsToAssociation) && super.enter(association);
		}
		
		override public function visit(association:AssociationProxy):void
		{
			super.visit(association);
			_isDirty = isDirty || (association.isDirty == true);
		}
		
		private var _isDirty:Boolean;
		public function get isDirty():Boolean
		{
			return _isDirty;
		}
	}
}