package mesh.services
{
	import collections.HashMap;
	
	import mesh.core.reflection.newInstance;
	import mesh.model.Entity;
	import mesh.operations.MethodOperation;
	import mesh.operations.Operation;
	
	public class TestService extends Service
	{
		private var _belongingToBlock:Function;
		
		private var _registry:HashMap = new HashMap();
		private var _idCounter:int;
		
		public function TestService(entity:Class, belongingToBlock:Function = null)
		{
			super(entity);
			_belongingToBlock = belongingToBlock;
		}
		
		override protected function createBelongingToOperation(entity:Entity, options:Object = null):Operation
		{
			return createOperation(function():Object
			{
				return _belongingToBlock == null ? [] : _belongingToBlock(entity, _registry.values());
			});
		}
		
		override protected function createFindOneOperation(id:*):Operation
		{
			return createOperation(function():Object
			{
				if (_registry.containsKey(id)) {
					return _registry.grab(id);
				}
				throw new ArgumentError("Entity not found with ID=" + id);
			});
		}
		
		override protected function createFindManyOperation(...ids):Operation
		{
			return createOperation(function():Object
			{
				var objects:Array = [];
				for each (var id:int in ids) {
					if (_registry.containsKey(id)) {
						objects.push(_registry.grab(id));
					} else {
						throw new ArgumentError("Entity not found with ID=" + id);
					}
				}
				return objects;
			});
		}
		
		override protected function createInsertOperation(entities:Array):Operation
		{
			return createOperation(function():void
			{
				for each (var entity:Entity in entities) {
					entity.id = ++_idCounter;
					_registry.put(entity.id, serialize([entity])[0]);
				}
			});
		}
		
		override protected function createDestroyOperation(entities:Array):Operation
		{
			return createOperation(function():void
			{
				for each (var entity:Entity in entities) {
					_registry.remove(entity.id);
				}
			});
		}
		
		override protected function createUpdateOperation(entities:Array):Operation
		{
			return createOperation(function():void
			{
				for each (var entity:Entity in entities) {
					_registry.put(entity.id, serialize([entity])[0]);
				}
			});
		}
		
		override protected function createOperation(...args):Operation
		{
			return newInstance.apply(null, [MethodOperation, args[0]]);
		}
		
		private function createPesistRequest(clazz:Class, entities:Array, block:Function):*
		{
			return newInstance(clazz, this, entities, function():Operation
			{
				return createOperation(block);
			});
		}
	}
}