package mesh.services
{
	import mesh.operations.Operation;
	
	public class DestroyRequest extends PersistRequest
	{
		public function DestroyRequest(entities:Array, adaptor:ServiceAdaptor, block:Function)
		{
			super(entities, adaptor, block);
		}
	}
}