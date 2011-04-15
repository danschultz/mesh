package mesh.services
{
	import mesh.operations.Operation;
	
	public class InsertRequest extends PersistRequest
	{
		public function InsertRequest(service:Service, entities:Array, block:Function)
		{
			super(service, entities, block);
		}
	}
}