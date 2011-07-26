package mesh.source
{
	import flash.errors.IllegalOperationError;
	
	import mesh.model.Entity;
	import mesh.model.Store;
	import mesh.model.query.Query;

	public class Source
	{
		public function Source()
		{
			
		}
		
		public function commit(store:Store, entities:Array):void
		{
			throw new IllegalOperationError("EntitySource.commit() is not implemented.");
		}
		
		public function create(store:Store, entity:Entity):void
		{
			throw new IllegalOperationError("EntitySource.createEntity() is not implemented.");
		}
		
		public function createEach(store:Store, entities:Array):void
		{
			for each (var entity:Entity in entities) {
				create(store, entity);
			}
		}
		
		public function destroy(store:Store, entity:Entity):void
		{
			throw new IllegalOperationError("EntitySource.destroyEntity() is not implemented.");
		}
		
		public function destroyEach(store:Store, entities:Array):void
		{
			for each (var entity:Entity in entities) {
				destroy(store, entity);
			}
		}
		
		public function fetch(query:Query):void
		{
			throw new IllegalOperationError("EntitySource.fetch() is not implemented.");
		}
		
		public function retrieve(store:Store, id:*):void
		{
			throw new IllegalOperationError("EntitySource.retrieveEntity() is not implemented.");
		}
		
		public function retrieveEach(store:Store, ids:Array):void
		{
			for each (var id:* in ids) {
				retrieve(store, id);
			}
		}
		
		public function update(store:Store, entity:Entity):void
		{
			throw new IllegalOperationError("EntitySource.updateEntity() is not implemented.");
		}
		
		public function updateEach(store:Store, entities:Array):void
		{
			for each (var entity:Entity in entities) {
				update(store, entity);
			}
		}
	}
}