package mesh
{
	import flash.utils.Dictionary;
	
	import mesh.associations.AssociationProxy;

	public class VisitOnceVisitor extends Visitor
	{
		private var _visited:Dictionary = new Dictionary();
		
		/**
		 * @copy Visitor#Visitor()
		 */
		public function VisitOnceVisitor()
		{
			super();
		}
		
		/**
		 * @inheritDoc
		 */
		override public function enter(association:AssociationProxy):Boolean
		{
			return _visited[association] === undefined;
		}
		
		/**
		 * @inheritDoc
		 */
		override public function visit(association:AssociationProxy):void
		{
			_visited[association] = true;
		}
	}
}