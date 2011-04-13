package mesh.services
{
	import mesh.adaptors.ServiceAdaptor;
	import mesh.operations.Operation;

	public class QueryRequest extends Request
	{
		private var _operation:Operation;
		
		public function QueryRequest(adaptor:ServiceAdaptor, block:Function)
		{
			super(adaptor, block);
		}
	}
}