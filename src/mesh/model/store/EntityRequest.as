package mesh.model.store
{
	import mesh.model.Entity;

	/**
	 * A request that wraps the loading of an entity's data.
	 * 
	 * @author Dan Schultz
	 */
	public class EntityRequest extends AsyncRequest
	{
		private var _entity:Entity;
		
		/**
		 * Constructor.
		 * 
		 * @param store The store.
		 * @param entity The entity to load.
		 * @param options An options hash.
		 */
		public function EntityRequest(store:Store, entity:Entity, options:Object = null)
		{
			super(store, entity, options);
			_entity = entity;
		}
		
		/**
		 * @inheritDoc
		 */
		override protected function executeRequest():void
		{
			super.executeRequest();
			//store.dataSource.retrieve(this, _entity);
		}
		
		/**
		 * @inheritDoc
		 */
		override protected function get isLoaded():Boolean
		{
			return _entity.status.isSynced;
		}
	}
}