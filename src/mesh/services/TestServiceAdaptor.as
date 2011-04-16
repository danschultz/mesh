package mesh.services
{
	import collections.HashMap;
	
	import mesh.core.reflection.newInstance;
	import mesh.model.Entity;
	import mesh.operations.MethodOperation;
	import mesh.operations.Operation;

	public class TestServiceAdaptor extends ServiceAdaptor
	{
		private var _registry:HashMap = new HashMap();
		private var _idCounter:int;
		
		public function TestServiceAdaptor(factory:Function, options:Object=null)
		{
			super(factory, options);
		}
		
		override protected function createOperation(...args):Operation
		{
			return newInstance.apply(null, [MethodOperation, args[0]]);
		}
		
		public function belongingTo(entity:Entity):Operation
		{
			return createOperation(function():void
			{
				for each (var object:Object in _registry) {
					
				}
			});
		}
		
		public function insert(entities:Array):Operation
		{
			return createOperation(function():void
			{
				for each (var entity:Entity in entities) {
					entity.id = ++_idCounter;
					_registry.put(entity.id, serialize([entity])[0]);
				}
			});
		}
		
		public function destroy(entities:Array):Operation
		{
			return createOperation(function():void
			{
				for each (var entity:Entity in entities) {
					_registry.remove(entity.id);
				}
			});
		}
		
		public function update(entities:Array):Operation
		{
			return createOperation(function():void
			{
				for each (var entity:Entity in entities) {
					_registry.put(entity.id, serialize([entity]));
				}
			});
		}
		
		public function findOne(id:int):Operation
		{
			return createOperation(function():Object
			{
				if (_registry.containsKey(id)) {
					var entities:Array = deserialize([_registry.grab(id)]);
					return entities[0];
				}
				throw new ArgumentError("Entity not found with ID=" + id);
			});
		}
		
		public function findMany(ids:Array):Operation
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
				return deserialize(objects);
			});
		}
	}
}