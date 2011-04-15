package mesh.services
{
	public class PersistRequest extends OperationRequest
	{
		private var _entities:Array;
		private var _service:Service;
		
		public function PersistRequest(service:Service, entities:Array, block:Function)
		{
			super(block);
			_entities = entities;
			_service = service;
		}

		protected function get service():Service
		{
			return _service;
		}

		public function get entities():Array
		{
			return _entities;
		}
	}
}