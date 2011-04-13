package mesh.services
{
	import mesh.adaptors.ServiceAdaptor;
	import mesh.operations.Operation;

	public class QueryRequest extends OperationRequest
	{
		private var _adaptor:ServiceAdaptor;
		
		public function QueryRequest(adaptor:ServiceAdaptor, block:Function)
		{
			super(block);
			_adaptor = adaptor;
		}
		
		override protected function blockArgs():Array
		{
			return [_adaptor];
		}
	}
}