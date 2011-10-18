package mesh.model.source
{
	import flash.errors.IllegalOperationError;
	
	import mesh.core.reflection.reflect;
	import mesh.model.Entity;
	import mesh.model.store.Commit;
	import mesh.model.store.Query;
	import mesh.model.store.ResultList;
	import mesh.model.store.Snapshot;
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
		
		public function create(commit:Commit, snapshot:Snapshot):void
		{
			throw new IllegalOperationError("Source.create() is not implemented.");
		}
		
		public function createEach(commit:Commit, snapshots:Array):void
		{
			for each (var snapshot:Snapshot in snapshots) {
				create(commit, snapshot);
			}
		}
		
		public function destroy(commit:Commit, snapshot:Snapshot):void
		{
			throw new IllegalOperationError("Source.destroy() is not implemented.");
		}
		
		public function destroyEach(commit:Commit, snapshots:Array):void
		{
			for each (var snapshot:Snapshot in snapshots) {
				destroy(commit, snapshot);
			}
		}
		
		public function fetch(query:Query, store:Store, results:ResultList):void
		{
			throw new IllegalOperationError("Source.fetch() is not implemented.");
		}
		
		public function retrieve(entity:Entity):void
		{
			throw new IllegalOperationError("Source.retrieve() is not implemented.");
		}
		
		public function retrieveEach(entities:Array):void
		{
			for each (var entity:Entity in entities) {
				retrieve(entity);
			}
		}
		
		public function update(commit:Commit, snapshot:Snapshot):void
		{
			throw new IllegalOperationError("Source.update() is not implemented.");
		}
		
		public function updateEach(commit:Commit, snapshots:Array):void
		{
			for each (var snapshot:Snapshot in snapshots) {
				update(commit, snapshot);
			}
		}
		
		/**
		 * Serializes the snapshots into a format that the server expects, such as XML, JSON or
		 * AMF.
		 * 
		 * @param snapshots The snapshots to serialize.
		 * @return An array of serialized entities.
		 */
		protected function serialize(snapshots:Array):Array
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