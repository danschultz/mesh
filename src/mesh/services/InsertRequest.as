package mesh.services
{
	public class InsertRequest extends SequentialRequest
	{
		public function InsertRequest(service:Service, entities:Array, block:Function)
		{
			super();
			add(new SaveRequest(service, entities, block));
			add(new AutoSaveRequest(entities));
		}
	}
}