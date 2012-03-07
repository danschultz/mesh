package mesh.model.source
{
	import flash.errors.IllegalOperationError;
	
	import mesh.model.Record;

	public class DataSource
	{
		public function DataSource()
		{
			
		}
		
		public function create(responder:IPersistenceResponder, snapshot:RecordSnapshot):void
		{
			throw new IllegalOperationError();
		}
		
		public function createEach(responder:IPersistenceResponder, snapshots:Array):void
		{
			for each (var snapshot:RecordSnapshot in snapshots) {
				create(responder, snapshot);
			}
		}
		
		public function destroy(responder:IPersistenceResponder, snapshot:RecordSnapshot):void
		{
			throw new IllegalOperationError();
		}
		
		public function destroyEach(responder:IPersistenceResponder, snapshots:Array):void
		{
			for each (var snapshot:RecordSnapshot in snapshots) {
				destroy(responder, snapshot);
			}
		}
		
		public function retrieve(responder:IRetrievalResponder, record:Record):void
		{
			throw new IllegalOperationError();
		}
		
		public function retrieveAll(responder:IRetrievalResponder, type:Class):void
		{
			throw new IllegalOperationError();
		}
		
		public function search(responder:IRetrievalResponder, type:Class, params:Object):void
		{
			throw new IllegalOperationError();
		}
		
		public function update(responder:IPersistenceResponder, snapshot:RecordSnapshot):void
		{
			throw new IllegalOperationError();
		}
		
		public function updateEach(responder:IPersistenceResponder, snapshots:Array):void
		{
			for each (var snapshot:RecordSnapshot in snapshots) {
				update(responder, snapshot);
			}
		}
	}
}