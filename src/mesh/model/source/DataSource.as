package mesh.model.source
{
	import flash.errors.IllegalOperationError;
	
	import mesh.operations.Operation;

	public class DataSource
	{
		public function DataSource()
		{
			
		}
		
		public function retrieve(recordType:Class, id:Object):Operation
		{
			throw new IllegalOperationError();
		}
		
		public function retrieveAll(recordType:Class):Operation
		{
			throw new IllegalOperationError();
		}
		
		public function search(recordType:Class, params:Object):Operation
		{
			throw new IllegalOperationError();
		}
	}
}