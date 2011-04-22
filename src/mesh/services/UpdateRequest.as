package mesh.services
{
	public class UpdateRequest extends SequentialRequest
	{
		public function UpdateRequest(service:Service, entities:Array, block:Function)
		{
			super();
			add(new SaveRequest(service, entities, block));
			add(new AutoSaveRequest(entities));
		}
	}
}