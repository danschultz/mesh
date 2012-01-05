package mesh.model.store
{
	public class StoreRequest
	{
		private var _store:Store;
		
		public function StoreRequest(store:Store)
		{
			_store = store;
		}
		
		public function execute():void
		{
			
		}
		
		public function fault(fault:Object):void
		{
			
		}
		
		public function result(data:Data):void
		{
			
		}
		
		protected function get store():Store
		{
			return _store;
		}
	}
}