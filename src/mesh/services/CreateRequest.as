package mesh.services
{
	import mesh.operations.Operation;
	
	public class CreateRequest extends PersistRequest
	{
		public function CreateRequest(operation:Operation, validate:Boolean)
		{
			super(operation, validate);
		}
	}
}