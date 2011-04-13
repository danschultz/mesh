package mesh.services
{
	import mesh.adaptors.ServiceAdaptor;
	
	public class PersistRequest extends OperationRequest
	{
		private var _adaptor:ServiceAdaptor;
		private var _entities:Array;
		
		public function PersistRequest(entities:Array, adaptor:ServiceAdaptor, block:Function)
		{
			super(block);
			_adaptor = adaptor;
			_entities = entities;
		}
		
		override protected function blockArgs():Array
		{
			return [_adaptor, _entities];
		}
	}
}