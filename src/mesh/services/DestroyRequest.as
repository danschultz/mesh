package mesh.services
{
	import mesh.model.Entity;

	public class DestroyRequest extends PersistRequest
	{
		public function DestroyRequest(service:Service, entities:Array, block:Function)
		{
			super("destroy", service, entities, block);
		}
	}
}