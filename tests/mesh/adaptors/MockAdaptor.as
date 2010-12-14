package mesh.adaptors
{
	import collections.HashMap;
	
	import mesh.Entity;
	
	import operations.EmptyOperation;
	import operations.MethodOperation;
	import operations.Operation;
	import operations.OperationEvent;

	public class MockAdaptor extends ServiceAdaptor
	{
		private static const DELAY:int = 50;
		
		private var _counter:int;
		private var _objects:HashMap = new HashMap();
		
		public function MockAdaptor(entity:Class, options:Object = null)
		{
			super(entity, options);
		}
		
		override public function create(entity:Entity):Operation
		{
			return update(entity);
		}
		
		override public function destroy(entity:Entity):Operation
		{
			return !entity.isDestroyed ? new MethodOperation(_objects.remove, entity.id) : new EmptyOperation();
		}
		
		override public function find(ids:Array):Operation
		{
			var items:Array = [];
			for each (var id:int in ids) {
				items.push(_objects.grab(id));
			}
			
			return new MethodOperation(items.concat);
		}
		
		override public function update(entity:Entity):Operation
		{
			var id:int = ++_counter;
			if (entity.isNew) {
				entity.id = id;
			}
			return new MethodOperation(_objects.put, id, entity.translateTo());
		}
		
		override public function where(options:Object):Operation
		{
			return find([options.id]);
		}
	}
}