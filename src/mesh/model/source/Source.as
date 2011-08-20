package mesh.model.source
{
	import flash.errors.IllegalOperationError;
	
	import mesh.core.reflection.reflect;
	import mesh.model.Entity;
	import mesh.model.store.Commit;
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
		
		public function commit(commit:Commit):void
		{
			if (commit.create.length > 0) {
				createEach(commit, commit.create);
			}
			
			if (commit.update.length > 0) {
				updateEach(commit, commit.update);
			}
			
			if (commit.destroy.length > 0) {
				destroyEach(commit, commit.destroy);
			}
		}
		
		public function create(commit:Commit, entity:Entity):void
		{
			throw new IllegalOperationError("EntitySource.create() is not implemented.");
		}
		
		public function createEach(commit:Commit, entities:Array):void
		{
			for each (var entity:Entity in entities) {
				create(commit, entity);
			}
		}
		
		public function destroy(commit:Commit, entity:Entity):void
		{
			throw new IllegalOperationError("EntitySource.destroy() is not implemented.");
		}
		
		public function destroyEach(commit:Commit, entities:Array):void
		{
			for each (var entity:Entity in entities) {
				destroy(commit, entity);
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
		
		public function update(commit:Commit, entity:Entity):void
		{
			throw new IllegalOperationError("EntitySource.update() is not implemented.");
		}
		
		public function updateEach(commit:Commit, entities:Array):void
		{
			for each (var entity:Entity in entities) {
				update(commit, entity);
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