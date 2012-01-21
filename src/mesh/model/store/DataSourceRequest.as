package mesh.model.store
{
	import flash.errors.IllegalOperationError;
	
	import mesh.model.source.DataSource;
	import mesh.operations.Operation;

	public class DataSourceRequest
	{
		private var _store:Store;
		private var _dataSource:DataSource;
		private var _proxy:Object;
		
		public function DataSourceRequest(store:Store, dataSource:DataSource, proxy:Object)
		{
			_store = store;
			_dataSource = dataSource;
			_proxy = proxy;
		}
		
		final public function execute():*
		{
			return _proxy;
		}
		
		protected function invoke(store:Store, dataSource:DataSource):Operation
		{
			throw new IllegalOperationError();
		}
	}
}