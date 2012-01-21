package mesh.model.source
{
	import flash.errors.IllegalOperationError;
	
	import mesh.model.store.DataSourceRequest;
	import mesh.model.store.RetrieveRequest;

	public class DataSource
	{
		public function DataSource()
		{
			
		}
		
		public function all(request:DataSourceRequest):void
		{
			throw new IllegalOperationError();
		}
		
		public function retrieve(request:RetrieveRequest):void
		{
			throw new IllegalOperationError();
		}
	}
}