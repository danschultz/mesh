package mesh.services
{
	import mesh.model.Entity;

	public class SaveRequest extends PersistRequest
	{
		public function SaveRequest(service:Service, entities:Array, block:Function)
		{
			super("save", service, entities, block);
		}
	}
}