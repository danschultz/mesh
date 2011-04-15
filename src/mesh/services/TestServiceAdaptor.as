package mesh.services
{
	import collections.HashMap;
	
	import mesh.Entity;
	import mesh.operations.MethodOperation;
	import mesh.operations.Operation;

	public class TestServiceAdaptor extends ServiceAdaptor
	{
		private var _registry:HashMap = new HashMap();
		private var _factory:Function;
		private var _idCounter:int;
		
		public function TestServiceAdaptor(factory:Function, options:Object=null)
		{
			super(options);
			_factory = factory;
		}
		
		override public function createOperation(...args):Operation
		{
			return this[args[0]].apply(null, args.slice(1));
		}
		
		override protected function deserialize(objects:Array):Array
		{
			return objects.map(function(object:Object, ...args):Entity
			{
				var entity:Entity = _factory(object);
				entity.translateFrom(object);
				return entity;
			});
		}
		
		override protected function serialize(entities:Array):Array
		{
			return entities.map(function(entity:Entity, ...args):Object
			{
				return entity.translateTo();
			});
		}
		
		public function belongingTo(entity:Entity):Operation
		{
			return new MethodOperation(function():void
			{
				for each (var object:Object in _registry) {
					
				}
			});
		}
		
		public function insert(entities:Array):Operation
		{
			return new MethodOperation(function():void
			{
				for each (var entity:Entity in entities) {
					entity.id = ++_idCounter;
					_registry.put(entity.id, serialize([entity])[0]);
				}
			});
		}
		
		public function destroy(entities:Array):Operation
		{
			return new MethodOperation(function():void
			{
				for each (var entity:Entity in entities) {
					_registry.remove(entity.id);
				}
			});
		}
		
		public function update(entities:Array):Operation
		{
			return new MethodOperation(function():void
			{
				for each (var entity:Entity in entities) {
					_registry.put(entity.id, serialize([entity]));
				}
			});
		}
		
		public function findOne(id:int):Operation
		{
			return new MethodOperation(function():Object
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
			return new MethodOperation(function():Object
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