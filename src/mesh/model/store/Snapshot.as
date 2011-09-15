package mesh.model.store
{
	import mesh.core.reflection.newInstance;
	import mesh.model.Entity;

	/**
	 * A <code>Snapshot</code> stores the values for an entity at the time a commit was created.
	 * 
	 * @see Commit
	 * @see Snapshots
	 * 
	 * @author Dan Schultz
	 */
	public class Snapshot
	{
		/**
		 * Creates a new snapshot of an entity.
		 * 
		 * @param entity The entity that the snapshot is of.
		 */
		public function Snapshot(entity:Entity)
		{
			_entity = entity;
			create();
		}
		
		private function create():void
		{
			_hash = entity.serialize();
		}
		
		/**
		 * Returns a new instance of the entity in the snapshot with the values that were taken
		 * when the snapshot was created.
		 * 
		 * @return A new entity.
		 */
		public function materialize():Entity
		{
			var entity:Entity = newInstance(entity.reflect.clazz);
			entity.fromObject(hash);
			return entity;
		}
		
		private var _entity:Entity;
		/**
		 * The entity for this snapshot.
		 */
		public function get entity():Entity
		{
			return _entity;
		}
		
		/**
		 * The entity's store key.
		 */
		public function get storeKey():Object
		{
			return entity.storeKey;
		}
		
		private var _hash:Object;
		/**
		 * The values of the entity when the snapshot was taken.
		 */
		public function get hash():Object
		{
			return _hash;
		}
	}
}