package mesh.model.source
{
	import flash.errors.IllegalOperationError;
	
	import mesh.model.Record;

	public class DataSource
	{
		public function DataSource()
		{
			
		}
		
		public function create(responder:IPersistenceResponder, snapshot:Snapshot):void
		{
			
		}
		
		public function createEach(responder:IPersistenceResponder, snapshots:Array):void
		{
			for each (var snapshot:Snapshot in snapshots) {
				create(responder, snapshot);
			}
		}
		
		public function belongingTo(responder:IRetrievalResponder, record:Record, type:Class):void
		{
			
		}
		
		public function destroy(responder:IPersistenceResponder, snapshot:Snapshot):void
		{
			
		}
		
		public function destroyEach(responder:IPersistenceResponder, snapshots:Array):void
		{
			for each (var snapshot:Snapshot in snapshots) {
				destroy(responder, snapshot);
			}
		}
		
		public function retrieve(responder:IRetrievalResponder, record:Record):void
		{
			
		}
		
		public function retrieveAll(responder:IRetrievalResponder, type:Class):void
		{
			
		}
		
		public function search(responder:IRetrievalResponder, type:Class, params:Object):void
		{
			
		}
		
		public function update(responder:IPersistenceResponder, snapshot:Snapshot):void
		{
			
		}
		
		public function updateEach(responder:IPersistenceResponder, snapshots:Array):void
		{
			for each (var snapshot:Snapshot in snapshots) {
				update(responder, snapshot);
			}
		}
	}
}