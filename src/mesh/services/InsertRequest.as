package mesh.services
{
	import mesh.operations.Operation;
	
	public class InsertRequest extends PersistRequest
	{
		public function InsertRequest(entities:Array, block:Function)
		{
			super(entities, block);
		}
	}
}