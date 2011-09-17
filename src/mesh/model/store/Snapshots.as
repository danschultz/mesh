package mesh.model.store
{
	import collections.HashSet;
	
	import flash.utils.Dictionary;
	
	import mesh.model.Entity;
	import mesh.model.source.Source;

	/**
	 * The <code>Snapshots</code> class holds the snapshots for each entity in a commit. A snapshot 
	 * contains the values of the entity at the time the commit was created.
	 * 
	 * @see #of()
	 * @see Commit
	 * @see Snapshot
	 * 
	 * @author Dan Schultz
	 */
	public class Snapshots
	{
		private var _commit:Commit;
		
		private var _committed:HashSet = new HashSet();
		
		private var _keyToSnapshot:Dictionary = new Dictionary();
		private var _snapshots:Array = [];
		
		private var _create:Array = [];
		private var _destroy:Array = [];
		private var _update:Array = [];
		
		/**
		 * Constructor.
		 * 
		 * @param commit The commit that owns these snapshots.
		 * @param entities The entities in the commit.
		 */
		public function Snapshots(commit:Commit, entities:Array)
		{
			_commit = commit;
			build(entities);
		}
		
		private function build(entities:Array):void
		{
			for each (var entity:Entity in entities) {
				var snapshot:Snapshot = new Snapshot(entity, this);
				_keyToSnapshot[entity.storeKey] = snapshot;
				_snapshots.push(snapshot);
				
				if (snapshot.status.isNew) {
					_create.push(snapshot);
				}
				
				if (snapshot.status.isDestroyed) {
					_destroy.push(snapshot);
				}
				
				if (snapshot.status.isPersisted) {
					_update.push(snapshot);
				}
			}
		}
		
		/**
		 * Commits the snapshot of each entity with the given key. If no keys are given, then
		 * all snapshots are committed.
		 * 
		 * @param dataSource The data source to commit to.
		 * @param keys The keys of the snapshots to commit.
		 */
		public function commit(dataSource:Source, keys:Array = null):void
		{
			dataSource.createEach(_commit, prepareSnapshotsForCommit(filterSnapshotsFor(_create, keys)));
			dataSource.destroyEach(_commit, filterSnapshotsFor(_destroy, keys));
			dataSource.updateEach(_commit, filterSnapshotsFor(_update, keys));
		}
		
		/**
		 * Marks each snapshot as being committed.
		 * 
		 * @param snapshots The snapshots to mark.
		 * @param ids The IDs given from the data source to each snapshot's entity.
		 */
		public function committed(snapshots:Array, ids:Array = null):void
		{
			var len:int = snapshots.length;
			for (var i:int = 0; i < len; i++) {
				snapshots[i].committed(ids != null ? ids[i] : null);
			}
			_committed.addAll(snapshots);
		}
		
		/**
		 * Checks if a snapshot exists for the given store key.
		 * 
		 * @param key The store key to check.
		 * @return <code>true</code> if a snapshot exists.
		 */
		public function contains(key:Object):Boolean
		{
			return key != null ? _keyToSnapshot[key] != null : false;
		}
		
		private function filterSnapshotsFor(snapshots:Array, keys:Array = null):Array
		{
			var result:Array = [];
			for each (var snapshot:Snapshot in snapshots) {
				if (_commit.isCommittable(snapshot.entity) && (keys == null || keys.indexOf(snapshot.storeKey) != -1)) {
					result.push(snapshot);
				}
			}
			return result;
		}
		
		/**
		 * Returns the snapshot that contains the values of the entity taken at the time the commit
		 * was created.
		 * 
		 * @param entity The entity to get the snapshot of.
		 * @return An object that contains the snapshot of the values that were taken
		 * 	on the entity.
		 */
		public function findByEntity(entity:Entity):Snapshot
		{
			return findByKey(entity.storeKey);
		}
		
		/**
		 * Returns the snapshot that contains the values of the entity with the given store key.
		 * 
		 * @param key The store key of the entity to get the snapshot for.
		 * @return An object that contains the snapshot of the values that were taken
		 * 	on the entity.
		 */
		public function findByKey(key:Object):Snapshot
		{
			if (!contains(key)) {
				throw new ArgumentError("Snapshot undefined for store key '" + key + "'");
			}
			return _keyToSnapshot[key];
		}
		
		private function prepareSnapshotsForCommit(snapshots:Array):Array
		{
			for each (var snapshot:Snapshot in snapshots) {
				snapshot.populateForeignKeys();
			}
			return snapshots;
		}
		
		/**
		 * The number of snapshots.
		 */
		public function get length():int
		{
			return _snapshots.length;
		}
	}
}