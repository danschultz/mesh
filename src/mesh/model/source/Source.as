package mesh.model.source
{
	import flash.errors.IllegalOperationError;
	
	import mesh.core.reflection.reflect;
	import mesh.model.Entity;
	import mesh.model.store.Query;
	import mesh.model.store.Store;

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
		
		/**
		 * Puts a list of entities into a busy state, which signifies that they're in the process
		 * of being created, updated or destroyed from the data source.
		 * 
		 * @param entities The entities to put into a busy state.
		 */
		protected function busy(entities:Array):void
		{
			for each (var entity:Entity in entities) {
				entity.busy();
			}
		}
		
		/**
		 * Marks a list of entities as being synced, which signifies that the entity's data and the 
		 * data source's data are the same. You may optionally pass a set of IDs to set on the
		 * entities. 
		 * 
		 * @param entities The entities to mark as synced.
		 * @param ids A list of IDs to populate the entities with.
		 */
		protected function synced(entities:Array, ids:Array = null):void
		{
			var len:int = entities.length;
			for (var i:int = 0; i < len; i++) {
				var entity:Entity = (entities[i] as Entity);
				if (ids != null) {
					entity.id = ids[i];
				}
				entity.synced();
			}
		}
		
		/**
		 * Marks a list of entities as erroring out while attempting to commit their data.
		 * 
		 * @param entities The entities to mark as errored.
		 */
		protected function errored(entities:Array):void
		{
			for each (var entity:Entity in entities) {
				entity.errored();
			}
		}
		
		/**
		 * Serializes the entities into a format that the server expects, such as XML, JSON or
		 * AMF.
		 * 
		 * @param entities The entities to serialize.
		 * @return An array of serialized entities.
		 */
		protected function serialize(entities:Array):Array
		{
			throw new IllegalOperationError(reflect(this).name + ".serialize() is not implemented.");
		}
		
		/**
		 * Deserializes the data retrieved from the server into entities.
		 * 
		 * @param data The data to deserialize.
		 * @return An array of deserialized entities.
		 */
		protected function deserialize(data:Array):Array
		{
			throw new IllegalOperationError(reflect(this).name + ".deserialize() is not implemented.");
		}
	}
}