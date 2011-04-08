package mesh
{
	import flash.utils.setTimeout;
	
	import mesh.adaptors.ServiceAdaptor;
	import mesh.core.reflection.clazz;
	
	import mesh.operations.Operation;
	import mesh.operations.ResultOperationEvent;
	
	public class Query
	{
		private var _adaptor:ServiceAdaptor;
		private var _entityType:Class;
		
		public function Query(entityType:Class, adaptor:ServiceAdaptor)
		{
			_entityType = entityType;
			_adaptor = adaptor;
		}
		
		public static function entity(entity:Object):Query
		{
			if (!(entity is Class)) {
				entity = clazz(entity);
			}
			return new Query(entity as Class, Entity.adaptorFor(entity));
		}
		
		public function all(options:Object = null):Operation
		{
			var operation:Operation = _adaptor.all(options);
			operation.addEventListener(ResultOperationEvent.RESULT, handleRetrieveResult);
			setTimeout(operation.execute, Mesh.DELAY);
			return operation;
		}
		
		public function find(...ids):Operation
		{
			if (ids[0] is Array) {
				ids = ids[0];
			}
			
			var operation:Operation = _adaptor.find(ids);
			operation.addEventListener(ResultOperationEvent.RESULT, handleRetrieveResult);
			setTimeout(operation.execute, Mesh.DELAY);
			return operation;
		}
		
		public function where(options:Object):Operation
		{
			var operation:Operation = _adaptor.where(options);
			operation.addEventListener(ResultOperationEvent.RESULT, handleRetrieveResult);
			setTimeout(operation.execute, Mesh.DELAY);
			return operation;
		}
		
		private function handleRetrieveResult(event:ResultOperationEvent):void
		{
			for (var i:int = 0; i < event.data.length; i++) {
				var entity:Entity = EntityDescription.describe(_entityType).newEntity(event.data[i]);
				entity.translateFrom(event.data[i]);
				entity.callback("afterFind");
				event.data[i] = entity;
			}
			
			if (event.data.length == 1) {
				event.data = event.data[0];
			}
		}
	}
}