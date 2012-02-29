package mesh.model.source
{
	import flash.errors.IllegalOperationError;
	
	import mesh.operations.Operation;
	import mesh.operations.ParallelOperation;

	public class DataSource
	{
		public function DataSource()
		{
			
		}
		
		public function create(recordType:Class, record:Object):Operation
		{
			throw new IllegalOperationError();
		}
		
		public function createEach(recordType:Class, records:Array):Operation
		{
			var operations:Array = [];
			for each (var record:Object in records) {
				operations.push(create(recordType, record));
			}
			return new ParallelOperation(operations);
		}
		
		public function destroy(recordType:Class, record:Object):Operation
		{
			throw new IllegalOperationError();
		}
		
		public function destroyEach(recordType:Class, records:Array):Operation
		{
			var operations:Array = [];
			for each (var record:Object in records) {
				operations.push(destroy(recordType, record));
			}
			return new ParallelOperation(operations);
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
		
		public function update(recordType:Class, record:Object):Operation
		{
			throw new IllegalOperationError();
		}
		
		public function updateEach(recordType:Class, records:Array):Operation
		{
			var operations:Array = [];
			for each (var record:Object in records) {
				operations.push(update(recordType, record));
			}
			return new ParallelOperation(operations);
		}
	}
}