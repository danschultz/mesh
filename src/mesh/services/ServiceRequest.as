package mesh.services
{
	public class ServiceRequest extends OperationRequest
	{
		public function ServiceRequest(service:Service, block:Function)
		{
			super(block);
			_service = service;
		}
		
		private var _service:Service;
		protected function get service():Service
		{
			return _service;
		}
	}
}