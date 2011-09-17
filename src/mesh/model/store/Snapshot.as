package mesh.model.store
{
	import mesh.core.object.copy;
	import mesh.core.reflection.newInstance;
	import mesh.model.Entity;
	import mesh.model.EntityStatus;
	import mesh.model.associations.Association;
	import mesh.model.associations.HasAssociation;

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
		private var _snapshots:Snapshots;
		
		/**
		 * Creates a new snapshot of an entity.
		 * 
		 * @param entity The entity that the snapshot is of.
		 * @param snapshots The class that created this snapshot.
		 */
		public function Snapshot(entity:Entity, snapshots:Snapshots)
		{
			_entity = entity;
			_snapshots = snapshots;
			create();
		}
		
		/**
		 * Called by the commit when this snapshot was successfully committed to the data source.
		 * 
		 * @param id The ID given to the entity of this snapshot from the data source.
		 */
		internal function committed(id:Object = null):void
		{
			_isCommitted = true;
			
			if (id != null) {
				entity.id = id;
			}
		}
		
		private function create():void
		{
			_status = new EntityStatus(entity.status.state);
			_hash = entity.serialize();
		}
		
		/**
		 * The store key for the entity of this snapshot.
		 * 
		 * @return The entity's store key.
		 */
		public function hashCode():Object
		{
			return storeKey;
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
		
		/**
		 * Called by the commit to repopulate any foreign keys on the hash.
		 */
		internal function populateForeignKeys():void
		{
			var keys:Array = [];
			for each (var association:Association in entity.associations) {
				if (association is HasAssociation) {
					keys.push((association as HasAssociation).foreignKey);
				}
			}
			copy(entity.serialize({only:keys}), _hash);
		}
		
		private var _entity:Entity;
		/**
		 * The entity for this snapshot.
		 */
		public function get entity():Entity
		{
			return _entity;
		}
		
		private var _isCommitted:Boolean;
		/**
		 * <code>true</code> if the entity of this snapshot has been committed.
		 */
		public function get isCommitted():Boolean
		{
			return _isCommitted;
		}
		
		private var _status:EntityStatus;
		/**
		 * The status of the entity when the commit was created.
		 */
		public function get status():EntityStatus
		{
			return _status;
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