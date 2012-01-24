package mesh.model.source
{
	import flash.errors.IllegalOperationError;
	
	import mesh.model.store.Store;
	import mesh.operations.Operation;

	public class DataSourceRequest
	{
		private var _store:Store;
		private var _proxy:Object;
		
		public function DataSourceRequest(store:Store, recordType:Class, proxy:Object)
		{
			_store = store;
			_recordType = recordType;
			_proxy = proxy;
		}
		
		final public function execute(dataSource:DataSource):*
		{
			invoke(_store, dataSource);
			return _proxy;
		}
		
		protected function invoke(store:Store, dataSource:DataSource):Operation
		{
			throw new IllegalOperationError();
		}
		
		override public function result(data:Object):void
		{
			
		}
		
		private var _recordType:Class;
		public function get recordType():Class
		{
			return _recordType;
		}
	}
}