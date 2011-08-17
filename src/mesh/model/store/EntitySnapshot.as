package mesh.model.store
{
	import flash.utils.Proxy;
	
	import mesh.mesh_internal;
	import mesh.model.Entity;
	
	/**
	 * The <code>StoreData</code> class stores the data of the individual entities
	 * belonging to a store.
	 * 
	 * @author Dan Schultz
	 */
	public dynamic class EntitySnapshot extends Proxy
	{
		/**
		 * Constructor.
		 * 
		 * @param entity The entity that the snapshot was taken from.
		 * @param state The state of the entity.
		 */
		public function EntitySnapshot(entity:Entity, state:int)
		{
			super();
			_entity = entity;
			_state = state;
		}
		
		private var _entity:Entity;
		/**
		 * The type of entity for the store data.
		 */
		mesh_internal function get entity():Entity
		{
			return _entity;
		}
		
		private var _state:int;
		/**
		 * The state of the entity when the snapshot was taken.
		 */
		mesh_internal function get state():int
		{
			return _state;
		}
	}
}