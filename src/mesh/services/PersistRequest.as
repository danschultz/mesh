package mesh.services
{
	import mesh.operations.Operation;
	
	public class PersistRequest extends Request
	{
		private var _validate:Boolean;
		
		public function PersistRequest(operation:Operation, validate:Boolean)
		{
			super(operation);
			_validate = validate;
		}
	}
}