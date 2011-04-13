package mesh.services
{
	import mesh.adaptors.ServiceAdaptor;
	import mesh.operations.Operation;
	
	public class PersistRequest extends Request
	{
		private var _entities:Array;
		
		public function PersistRequest(entities:Array, adaptor:ServiceAdaptor, block:Function)
		{
			super(adaptor, block);
			_entities = entities;
		}
		
		override protected function executeBlock(block:Function, adaptor:ServiceAdaptor):Operation
		{
			return block(adaptor, _entities);
		}
	}
}