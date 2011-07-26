package mesh.source
{
	import flash.errors.IllegalOperationError;
	
	import mesh.model.Entity;
	import mesh.model.EntityStore;
	import mesh.model.query.Query;

	public class EntitySource
	{
		public function EntitySource()
		{
			
		}
		
		public function commit(store:EntityStore, entities:Array):void
		{
			throw new IllegalOperationError("EntitySource.commit() is not implemented.");
		}
		
		public function create(store:EntityStore, entity:Entity):void
		{
			throw new IllegalOperationError("EntitySource.createEntity() is not implemented.");
		}
		
		public function createEach(store:EntityStore, entities:Array):void
		{
			for each (var entity:Entity in entities) {
				create(store, entity);
			}
		}
		
		public function destroy(store:EntityStore, entity:Entity):void
		{
			throw new IllegalOperationError("EntitySource.destroyEntity() is not implemented.");
		}
		
		public function destroyEach(store:EntityStore, entities:Array):void
		{
			for each (var entity:Entity in entities) {
				destroy(store, entity);
			}
		}
		
		public function fetch(query:Query):void
		{
			throw new IllegalOperationError("EntitySource.fetch() is not implemented.");
		}
		
		public function retrieve(store:EntityStore, id:*):void
		{
			throw new IllegalOperationError("EntitySource.retrieveEntity() is not implemented.");
		}
		
		public function retrieveEach(store:EntityStore, ids:Array):void
		{
			for each (var id:* in ids) {
				retrieve(store, id);
			}
		}
		
		public function update(store:EntityStore, entity:Entity):void
		{
			throw new IllegalOperationError("EntitySource.updateEntity() is not implemented.");
		}
		
		public function updateEach(store:EntityStore, entities:Array):void
		{
			for each (var entity:Entity in entities) {
				update(store, entity);
			}
		}
	}
}