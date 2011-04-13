package mesh.services
{
	import mesh.operations.Operation;
	
	public class UpdateRequest extends PersistRequest
	{
		public function UpdateRequest(operation:Operation)
		{
			super(operation);
		}
	}
}