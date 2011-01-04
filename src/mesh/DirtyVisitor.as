package mesh
{
	import flash.utils.Dictionary;
	
	import mesh.associations.AssociationProxy;

	public dynamic class DirtyVisitor extends Visitor
	{
		private var _results:Dictionary = new Dictionary();
		
		public function DirtyVisitor()
		{
			super();
		}
		
		override public function enter(association:AssociationProxy):Boolean
		{
			return _results[association] === undefined;
		}
		
		override public function visit(association:AssociationProxy):void
		{
			_results[association] = association.isDirty;
			_isDirty = isDirty || (_results[association] == true);
		}
		
		private var _isDirty:Boolean;
		public function get isDirty():Boolean
		{
			return _isDirty;
		}
	}
}