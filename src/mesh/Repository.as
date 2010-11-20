package mesh
{
	import collections.HashSet;
	
	import operations.EmptyOperation;
	import operations.Operation;
	
	public class Repository
	{
		private var _entities:HashSet = new HashSet();
		
		private var _insertedEntities:HashSet = new HashSet();
		private var _removedEntities:HashSet = new HashSet();
		private var _updatedEntities:HashSet = new HashSet();
		
		private var _model:EntityModel;
		
		public function Repository(model:EntityModel)
		{
			_model = model;
		}
		
		public function commit():Operation
		{
			return new EmptyOperation();
		}
		
		public function fetch(request:FetchRequest):void
		{
			
		}
		
		public function insert(entity:Entity):void
		{
			_insertedEntities.add(entity);
			_removedEntities.remove(entity);
			register(entity);
		}
		
		public function remove(entity:Entity):void
		{
			_insertedEntities.remove(entity);
			_removedEntities.add(entity);
			unregister(entity);
		}
		
		public function register(entity:Entity):void
		{
			_entities.add(entity);
		}
		
		public function unregister(entity:Entity):void
		{
			_entities.remove(entity);
		}
	}
}