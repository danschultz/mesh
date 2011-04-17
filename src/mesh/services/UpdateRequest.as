package mesh.services
{
	public class UpdateRequest extends SaveRequest
	{
		public function UpdateRequest(service:Service, entities:Array, block:Function)
		{
			super(service, entities, block);
		}
	}
}