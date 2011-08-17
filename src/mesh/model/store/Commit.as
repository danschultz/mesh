package mesh.model.store
{
	import mesh.model.source.Source;

	/**
	 * The <code>Commit</code> class encapsulates the state of each dirty entity that needs
	 * to be synced with the data source.
	 * 
	 * @author Dan Schultz
	 */
	public class Commit
	{
		private var _store:Store;
		private var _source:Source;
		private var _entities:Array;
		
		/**
		 * Constructor.
		 * 
		 * @param store The store that the commit originates from.
		 * @param source The source to commit the entities to.
		 * @param entities The snapshots of each entity to commit.
		 */
		public function Commit(store:Store, source:Source, entities:Array)
		{
			_store = store;
			_source = source;
			_entities = entities
		}
		
		/**
		 * Executes the persistence of the entities in this commit to their data source.
		 */
		public function save():void
		{
			_source.commit(_store, _entities);
		}
	}
}