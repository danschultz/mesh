package mesh.services
{
	import mesh.core.string.capitalize;
	import mesh.model.Entity;

	public class PersistRequest extends OperationRequest
	{
		private var _callback:String;
		private var _entities:Array;
		private var _service:Service;
		
		public function PersistRequest(callback:String, service:Service, entities:Array, block:Function)
		{
			super(block);
			_callback = capitalize(callback);
			_entities = entities;
			_service = service;
		}
		
		override protected function executeBlock(block:Function):void
		{
			for each (var entity:Entity in entities) {
				//entity.callback("before" + _callback);
			}
			super.executeBlock(block);
		}
		
		override protected function success():void
		{
			for each (var entity:Entity in entities) {
				//entity.callback("after" + _callback);
			}
			super.success();
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