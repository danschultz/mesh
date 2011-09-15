package mesh.model.store
{
	import flash.utils.Dictionary;
	
	import mesh.model.Entity;

	/**
	 * The <code>Snapshots</code> class holds the snapshots for each entity in a commit. A snapshot 
	 * contains the values of the entity at the time the commit was created. To retrieve the snapshot
	 * of an entity, call the <code>of()</code> method.
	 * 
	 * @see #of()
	 * @see Commit
	 * @see Snapshot
	 * 
	 * @author Dan Schultz
	 */
	public class Snapshots
	{
		private var _entities:Array;
		private var _entityToSnapshot:Dictionary = new Dictionary();
		
		/**
		 * Constructor.
		 * 
		 * @param entities The entities in the commit.
		 */
		public function Snapshots(entities:Array)
		{
			_entities = entities;
			create();
		}
		
		private function create():void
		{
			for each (var entity:Entity in _entities) {
				_entityToSnapshot[entity] = new Snapshot(entity);
			}
		}
		
		/**
		 * Returns the snapshot that contains the values of the entity taken at the time the commit
		 * was created.
		 * 
		 * @param entity The entity to get the snapshot of.
		 * @return An object that contains the snapshot of the values that were taken
		 * 	on the entity.
		 */
		public function of(entity:Entity):Snapshot
		{
			if (_entityToSnapshot[entity] == null) {
				throw new ArgumentError("Snapshot undefined for '" + entity + "'");
			}
			return _entityToSnapshot[entity];
		}
	}
}
