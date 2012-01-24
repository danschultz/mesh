package mesh.model.source
{
	import flash.errors.IllegalOperationError;

	public class DataSource
	{
		public function DataSource()
		{
			
		}
		
		public function retrieve(request:DataSourceRequest, recordType:Class, id:Object):void
		{
			throw new IllegalOperationError();
		}
		
		public function retrieveAll(request:DataSourceRequest, recordType:Class):void
		{
			throw new IllegalOperationError();
		}
	}
}