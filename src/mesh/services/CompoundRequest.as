package mesh.services
{
	import mesh.operations.Operation;
	
	public class CompoundRequest extends Request
	{
		private var _operation:Operation;
		
		public function CompoundRequest(operation:Operation)
		{
			super(operation);
		}
		
		public function then(request:Request):CompoundRequest
		{
			
		}
	}
}