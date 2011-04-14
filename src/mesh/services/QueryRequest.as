package mesh.services
{
	public class QueryRequest extends OperationRequest
	{
		private var _service:Service;
		
		public function QueryRequest(block:Function)
		{
			super(block);
			_service = service;
		}
		
		override protected function result(data:Object):void
		{
			_service.register(data);
			super.result(data);
		}
	}
}