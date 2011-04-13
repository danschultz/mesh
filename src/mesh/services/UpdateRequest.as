package mesh.services
{
	import mesh.operations.Operation;
	
	public class UpdateRequest extends PersistRequest
	{
		public function UpdateRequest(entities:Array, adaptor:ServiceAdaptor, block:Function)
		{
			super(entities, adaptor, block);
		}
	}
}