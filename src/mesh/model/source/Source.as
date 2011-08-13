package mesh.model.source
{
	import flash.errors.IllegalOperationError;
	
	import mesh.model.Entity;
	import mesh.model.Store;
	import mesh.model.query.Query;

	/**
	 * The <code>Source</code> class is responsible for persisting an <code>Entity</code>.
	 * The class defines methods for creating, retrieving, updating and destroying an entity.
	 * These methods must be overridden by sub-classes to perform the persistence.
	 * 
	 * @author Dan Schultz
	 */
	public class Source
	{
		/**
		 * Constructor.
		 */
		public function Source()
		{
			
		}
		
		public function commit(store:Store, entities:Array):void
		{
			createEach(store, entities.filter(function(entity:Entity, ...args):Boolean
			{
				return entity.isNew && entity.isDirty;
			}));
			
			updateEach(store, entities.filter(function(entity:Entity, ...args):Boolean
			{
				return entity.isPersisted && entity.isDirty;
			}));
			
			destroyEach(store, entities.filter(function(entity:Entity, ...args):Boolean
			{
				return entity.isDestroyed && entity.isDirty;
			}));
		}
		
		public function create(store:Store, entity:Entity):void
		{
			throw new IllegalOperationError("EntitySource.create() is not implemented.");
		}
		
		public function createEach(store:Store, entities:Array):void
		{
			for each (var entity:Entity in entities) {
				create(store, entity);
			}
		}
		
		public function destroy(store:Store, entity:Entity):void
		{
			throw new IllegalOperationError("EntitySource.destroy() is not implemented.");
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
		
		public function retrieve(store:Store, entity:Entity):void
		{
			throw new IllegalOperationError("EntitySource.retrieve() is not implemented.");
		}
		
		public function retrieveEach(store:Store, entities:Array):void
		{
			for each (var entity:Entity in entities) {
				retrieve(store, entity);
			}
		}
		
		public function update(store:Store, entity:Entity):void
		{
			throw new IllegalOperationError("EntitySource.update() is not implemented.");
		}
		
		public function updateEach(store:Store, entities:Array):void
		{
			for each (var entity:Entity in entities) {
				update(store, entity);
			}
		}
	}
}