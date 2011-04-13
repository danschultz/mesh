package mesh.services
{
	import mesh.operations.Operation;
	
	public class CreateRequest extends PersistRequest
	{
		public function CreateRequest(entities:Array, adaptor:ServiceAdaptor, block:Function)
		{
			super(entities, adaptor, block);
		}
	}
}