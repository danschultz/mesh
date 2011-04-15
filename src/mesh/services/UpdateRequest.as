package mesh.services
{
	public class UpdateRequest extends PersistRequest
	{
		public function UpdateRequest(service:Service, entities:Array, block:Function)
		{
			super(service, entities, block);
		}
	}
}