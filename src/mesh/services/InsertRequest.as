package mesh.services
{
	import mesh.model.Entity;
	import mesh.operations.Operation;
	
	public class InsertRequest extends SaveRequest
	{
		public function InsertRequest(service:Service, entities:Array, block:Function)
		{
			super(service, entities, block);
		}
	}
}