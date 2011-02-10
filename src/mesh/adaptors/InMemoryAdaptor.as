package mesh.adaptors
{
	import collections.HashMap;
	
	import mesh.Entity;
	import mesh.core.functions.closure;
	
	import operations.FinishedOperationEvent;
	import operations.MethodOperation;
	import operations.Operation;
	import operations.OperationEvent;
	import operations.SequentialOperation;

	public class InMemoryAdaptor extends ServiceAdaptor
	{
		private var _entities:HashMap = new HashMap();
		private var _counter:int;
		
		/**
		 * @copy ServiceAdaptor#ServiceAdaptor()
		 */
		public function InMemoryAdaptor(entity:Class, options:Object = null)
		{
			super(entity, options);
		}
		
		/**
		 * @inheritDoc
		 */
		override public function create(entities:Array):Operation
		{
			var sequence:SequentialOperation = new SequentialOperation();
			entities.forEach(closure(function(entity:Entity):void
			{
				var id:int = ++_counter;
				var operation:MethodOperation = new MethodOperation(_entities.put, id, entity);
				operation.addEventListener(OperationEvent.BEFORE_EXECUTE, function(event:OperationEvent):void
				{
					if (entity.isPersisted) {
						operation.fault("Cannot create a persisted entity.");
					}
				});
				operation.addEventListener(FinishedOperationEvent.FINISHED, function(event:FinishedOperationEvent):void
				{
					entity.id = id;
				});
				sequence.add(operation);
			}));
			return sequence;
		}
		
		/**
		 * @inheritDoc
		 */
		override public function destroy(entities:Array):Operation
		{
			var sequence:SequentialOperation = new SequentialOperation();
			entities.forEach(closure(function(entity:Entity):void
			{
				var operation:Operation = new MethodOperation(_entities.remove, entity.id);
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
		
		/**
		 * @inheritDoc
		 */
		override public function retrieve(options:Object):Operation
		{
			return new MethodOperation(_entities.grab, options.id);
		}
		
		/**
		 * @inheritDoc
		 */
		override public function update(entities:Array):Operation
		{
			var sequence:SequentialOperation = new SequentialOperation();
			entities.forEach(closure(function(entity:Entity):void
			{
				var operation:MethodOperation = new MethodOperation(_entities.put, entity.id, entity);
				operation.addEventListener(OperationEvent.BEFORE_EXECUTE, function(event:OperationEvent):void
				{
					if (!entity.isPersisted) {
						event.operation.fault("Cannot update a non-persisted entity.");
					}
				});
				sequence.add(operation);
			}));
			return sequence;
		}
	}
}