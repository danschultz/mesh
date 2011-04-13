package mesh.services
{
	import mesh.operations.Operation;

	public class Query extends Request
	{
		private var _operation:Operation;
		
		public function Query(operation:Operation)
		{
			super(operation);
		}
	}
}