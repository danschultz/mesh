package mesh.services
{
	import mesh.adaptors.ServiceAdaptor;
	import mesh.operations.Operation;
	
	public class InsertRequest extends PersistRequest
	{
		public function InsertRequest(entities:Array, adaptor:ServiceAdaptor, block:Function)
		{
			super(entities, adaptor, block);
		}
	}
}