package mesh.model.associations
{
	import flash.errors.IllegalOperationError;
	import flash.events.Event;
	
	import mesh.model.Entity;
	
	import mx.binding.utils.ChangeWatcher;
	
	/**
	 * The base class for any association that links to a single entity.
	 * 
	 * @author Dan Schultz
	 */
	public class HasAssociation extends Association
	{
		/**
		 * @copy AssociationProxy#AssociationProxy()
		 */
		public function HasAssociation(owner:Entity, property:String, options:Object = null)
		{
			super(owner, property, options);
		}
		
		/**
		 * @inheritDoc
		 */
		override protected function entityDestroyed(entity:Entity):void
		{
			owner[property] = null;
			associate(entity, false);
		}
		
		/**
		 * @inheritDoc
		 */
		override protected function entityRevived(entity:Entity):void
		{
			owner[property] = entity;
		}
		
		private var _loadingEntity:Entity;
		private var _loadingEntityWatcher:ChangeWatcher;
		/**
		 * @inheritDoc
		 */
		override protected function loadRequested():void
		{
			super.loadRequested();
			
			if (_loadingEntity == null) {
				_loadingEntity = owner.store.find(entityType, owner[foreignKey]);
				_loadingEntityWatcher = ChangeWatcher.watch(_loadingEntity.status, "isSynced", function(event:Event):void
				{
					loaded(_loadingEntity);
				});
			}
		}
		
		/**
		 * @inheritDoc
		 */
		override protected function loaded(data:Object):void
		{
			super.loaded(data);
			_loadingEntity = null;
			
			if (_loadingEntityWatcher != null) {
				_loadingEntityWatcher.unwatch();
				_loadingEntityWatcher = null;
			}
		}
		
		/**
		 * The property on the owner that defines the foreign key to load this association.
		 */
		protected function get foreignKey():String
		{
			if (options.foreignKey == null || !owner.hasOwnProperty(options.foreignKey)) {
				throw new IllegalOperationError("Undefined foreign key for " + this);
			}
			return options.foreignKey;
		}
		
		/**
		 * The associated type of entity. If the type is not defined as an option, then the association
		 * will look up the type defined on the entity through reflection.
		 */
		protected function get entityType():Class
		{
			try {
				return options.entityType != null ? options.entityType : owner.reflect.property(property).type.clazz;
			} catch (e:Error) {
				
			}
			throw new IllegalOperationError("Undefined entity type for " + this);
		}
		
		/**
		 * @inheritDoc
		 */
		override public function set object(value:*):void
		{
			if (object != null) unassociate(object);
			super.object = value;
			if (object != null) associate(object, true);
		}
	}
}