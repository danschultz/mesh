package mesh.model.source
{
	import flash.errors.IllegalOperationError;
	

	public class DataSource
	{
		public function DataSource()
		{
			
		}
		
		public function retrieve(request:RetrieveRequest):void
		{
			throw new IllegalOperationError();
		}
		
		public function retrieveAll(request:DataSourceRequest):void
		{
			throw new IllegalOperationError();
		}
	}
}