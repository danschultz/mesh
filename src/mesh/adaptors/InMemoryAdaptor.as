package mesh.adaptors
{
	import collections.HashMap;
	
	import mesh.Entity;
	import mesh.associations.Relationship;
	
	import operations.FinishedOperationEvent;
	import operations.MethodOperation;
	import operations.Operation;
	import operations.ResultOperationEvent;

	public class InMemoryAdaptor extends ServiceAdaptor
	{
		private var _entities:HashMap = new HashMap();
		private var _counter:int;
		
		/**
		 * @copy ServiceAdaptor#ServiceAdaptor()
		 */
		public function InMemoryAdaptor(entity:Class, options:Object)
		{
			super(entity, options);
		}
		
		/**
		 * @inheritDoc
		 */
		override public function belongingTo(entity:Entity, relationship:Relationship):Operation
		{
			var operation:Operation = Entity.adaptorFor(entity).retrieve({id:entity.id});
			operation.addEventListener(ResultOperationEvent.RESULT, function(event:ResultOperationEvent):void
			{
				event.data = event.data[relationship.property];
			});
			return operation;
		}
		
		/**
		 * @inheritDoc
		 */
		override public function create(entity:Entity):Operation
		{
			var id:int = ++_counter;
			var operation:MethodOperation = new MethodOperation(_entities.put, id, entity);
			operation.addEventListener(FinishedOperationEvent.FINISHED, function(event:FinishedOperationEvent):void
			{
				entity.id = id;
			});
			return operation;
		}
		
		/**
		 * @inheritDoc
		 */
		override public function destroy(entity:Entity):Operation
		{
			return new MethodOperation(_entities.remove, entity.id);
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
		override public function update(entity:Entity):Operation
		{
			return new MethodOperation(_entities.put, entity.id, entity);
		}
	}
}