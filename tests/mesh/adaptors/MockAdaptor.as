package mesh.adaptors
{
	import collections.HashMap;
	
	import mesh.core.functions.closure;
	
	import mesh.Entity;
	
	import operations.MethodOperation;
	import operations.Operation;
	import operations.OperationEvent;
	import operations.SequentialOperation;

	public class MockAdaptor extends ServiceAdaptor
	{
		private static const DELAY:int = 50;
		
		private var _counter:int;
		private var _objects:HashMap = new HashMap();
		
		public function MockAdaptor(entity:Class, options:Object = null)
		{
			super(entity, options);
		}
		
		override public function create(entities:Array):Operation
		{
			return update(entities);
		}
		
		override public function destroy(entities:Array):Operation
		{
			var sequence:SequentialOperation = new SequentialOperation();
			entities.forEach(closure(function(entity:Entity):void
			{
				var operation:Operation = new MethodOperation(_objects.remove, entity.id);
				operation.addEventListener(OperationEvent.BEFORE_EXECUTE, function(event:OperationEvent):void
				{
					if (!entity.isPersisted) {
						operation.fault("Cannot remove entity that is not persisted.");
					}
				});
				sequence.add(operation);
			}));
			return sequence;
		}
		
		override public function find(ids:Array):Operation
		{
			var items:Array = [];
			for each (var id:int in ids) {
				items.push(_objects.grab(id));
			}
			
			return new MethodOperation(items.concat);
		}
		
		override public function update(entities:Array):Operation
		{
			var sequence:SequentialOperation = new SequentialOperation();
			entities.forEach(closure(function(entity:Entity):void
			{
				if (entity.isNew) {
					entity.id = ++_counter;
				}
				sequence.add( new MethodOperation(_objects.put, entity.id, entity.translateTo()) );
			}));
			return sequence;
		}
		
		override public function where(options:Object):Operation
		{
			return find([options.id]);
		}
	}
}