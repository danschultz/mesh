package mesh.services
{
	public class PersistRequest extends OperationRequest
	{
		private var _entities:Array;
		
		public function PersistRequest(entities:Array, block:Function)
		{
			super(block);
			_entities = entities;
		}
	}
}