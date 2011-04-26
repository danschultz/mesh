package mesh.services
{
	import mesh.core.array.flatten;
	import mesh.model.Entity;

	public dynamic class QueryRequest extends ServiceRequest
	{
		private var _deserializer:Function;
		
		public function QueryRequest(service:Service, deserializer:Function, block:Function)
		{
			super(service, block);
			_deserializer = deserializer;
		}
		
		override protected function result(data:Object):void
		{
			if (data.hasOwnProperty("toArray")) {
				data = data.toArray();
			}
			
			var result:Array = _deserializer(flatten(data));
			for each (var entity:Entity in result) {
				entity.callback("afterFind");
			}
			
			data = result;
			service.register(data);
			super.result(data);
		}
	}
}