package mesh.services
{
	public class DestroyRequest extends PersistRequest
	{
		public function DestroyRequest(service:Service, entities:Array, block:Function)
		{
			super(service, entities, block);
		}
		
		override protected function success():void
		{
			service.unregister(entities);
			super.success();
		}
	}
}