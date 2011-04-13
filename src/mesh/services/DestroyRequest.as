package mesh.services
{
	import mesh.operations.Operation;
	
	public class DestroyRequest extends PersistRequest
	{
		public function DestroyRequest(operation:Operation)
		{
			super(operation);
		}
	}
}