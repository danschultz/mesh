package mesh.services
{
	import mesh.core.array.flatten;

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
			
			data = _deserializer(flatten(data));
			service.register(data);
			super.result(data);
		}
	}
}