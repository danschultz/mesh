package mesh
{
	import collections.ArrayList;

	public class AssociationCollection extends AssociationProxy
	{
		private var _entities:ArrayList = new ArrayList();
		
		public function AssociationCollection(source:Entity, relationship:Relationship)
		{
			super(source, relationship);
			target = _entities;
		}
		
		public function add(entity:Entity):void
		{
			_entities.add(entity);
		}
		
		public function remove(entity:Entity):void
		{
			_entities.remove(entity);
		}
	}
}