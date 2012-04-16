package mesh.model.source
{
	import flash.errors.IllegalOperationError;
	import flash.utils.Dictionary;
	
	import mesh.core.array.ArrayProxy;
	import mesh.model.Record;
	import mesh.model.store.Cache;

	/**
	 * The <code>Snapshots</code> class contains a set of grouped snapshots. The snapshots
	 * are grouped by their record type, and by their save action (i.e. create, update, 
	 * destroy).
	 * 
	 * @author Dan Schultz
	 */
	public class Snapshots extends ArrayProxy
	{
		private var _cache:SnapshotCache;
		private var _snapshots:Array;
		private var _recordToSnapshot:Dictionary = new Dictionary();
		
		private var _grouped:Boolean = false;
		
		/**
		 * Constructor.
		 * 
		 * @param snapshots The snapshots.
		 */
		public function Snapshots(snapshots:Array)
		{
			super(snapshots.concat);
			_snapshots = snapshots;
		}
		
		/**
		 * Creates a new set of snapshots from a list of records.
		 * 
		 * @param records The records to create snapshots for.
		 * @return A new set of snapshots.
		 */
		public static function create(records:Array):Snapshots
		{
			var snapshots:Array = [];
			for each (var record:Record in records) {
				snapshots.push( new Snapshot(record) );
			}
			return new Snapshots(snapshots);
		}
		
		/**
		 * Checks if a record or snapshot belongs to this set.
		 * 
		 * @param recordOrSnapshot A <code>Record</code> or <code>Snapshot</code>.
		 * @return <code>true</code> if the record or snapshot exists.
		 */
		public function contains(recordOrSnapshot:Object):Boolean
		{
			var record:Record = (recordOrSnapshot is Snapshot) ? (recordOrSnapshot as Snapshot).record : Record( recordOrSnapshot );
			return _recordToSnapshot[record] != null;
		}
		
		/**
		 * Returns all the snapshots for the given type of record.
		 * 
		 * @param type The type of record to get the snapshots for.
		 * @return A set of snapshots.
		 */
		public function findByType(type:Class):Snapshots
		{
			if (_cache == null) {
				_cache = new SnapshotCache(_snapshots);
			}
			return new Snapshots(_cache.findIndex(type).toArray());
		}
		
		private function chooseArray(snapshot:Snapshot):Array
		{
			if (snapshot.state.willBeCreated) {
				return _create;
			}
			
			if (snapshot.state.willBeUpdated) {
				return _update;
			}
			
			if (snapshot.state.willBeDestroyed) {
				return _destroy;
			}
			
			throw new IllegalOperationError("Cannot commit record");
		}
		
		private function group():void
		{
			if (!_grouped) {
				for each (var snapshot:Snapshot in _snapshots) {
					if (!snapshot.state.isSynced) {
						chooseArray(snapshot).push(snapshot);
						_recordToSnapshot[snapshot.record] = snapshot;
					}
				}
				_grouped = true;
			}
		}
		
		private var _create:Array = [];
		/**
		 * The snapshots that need to be created.
		 */
		public function get create():Array
		{
			group();
			return _create.concat();
		}
		
		private var _destroy:Array = [];
		/**
		 * The snapshots that need to be destroyed.
		 */
		public function get destroy():Array
		{
			group();
			return _destroy.concat();
		}
		
		private var _update:Array = [];
		/**
		 * The snapshots that need to be udpated.
		 */
		public function get update():Array
		{
			group();
			return _update.concat();
		}
		
		/**
		 * The number of snapshots in this set.
		 */
		public function get length():int
		{
			return _snapshots.length;
		}
	}
}

import mesh.model.source.Snapshot;
import mesh.model.store.Cache;

class SnapshotCache extends Cache
{
	public function SnapshotCache(snapshots:Array)
	{
		for each (var snapshot:Snapshot in snapshots) {
			insert(snapshot);
		}
	}
	
	override protected function determineType(data:Object):Class
	{
		return (data as Snapshot).record.reflect.clazz;
	}
}