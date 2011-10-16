package mesh.model.associations
{
	import flash.errors.IllegalOperationError;
	
	import mesh.model.Entity;
	import mesh.model.store.AsyncRequest;
	
	import mx.events.PropertyChangeEvent;
	
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
			checkForRequiredFields();
		}
		
		/**
		 * @inheritDoc
		 */
		override protected function associate(entity:Entity):void
		{
			super.associate(entity);
			populateForeignKey();
			entity.addEventListener(PropertyChangeEvent.PROPERTY_CHANGE, handleAssociatedEntityPropertyChange);
		}
		
		private function checkForRequiredFields():void
		{
			if (entityType == null) throw new IllegalOperationError("Undefined entity type for " + this);
			if (options.foreignKey != null && !owner.hasOwnProperty(options.foreignKey)) throw new IllegalOperationError("Undefined foreign key '" + options.foreignKey + " for " + this);
		}
		
		/**
		 * @inheritDoc
		 */
		override protected function createLoadRequest():AsyncRequest
		{
			return owner.store.findAsync(entityType, owner[foreignKey]);
		}
		
		private function handleAssociatedEntityPropertyChange(event:PropertyChangeEvent):void
		{
			if (event.property == "id") {
				populateForeignKey();
			}
		}
		
		private function populateForeignKey():void
		{
			// If the foreign key is undefined, try to automagically set it.
			var key:String = foreignKey;
			
			if (owner.hasOwnProperty(key)) {
				owner[key] = object.id;
			}
		}
		
		private function unassociateForeignKey():void
		{
			// If the foreign key is undefined, try to automagically set it.
			var key:String = foreignKey;
			
			if (owner.hasOwnProperty(key)) {
				owner[key] = null;
			}
		}
		
		/**
		 * @inheritDoc
		 */
		override protected function unassociate(entity:Entity):void
		{
			super.unassociate(entity);
			entity.removeEventListener(PropertyChangeEvent.PROPERTY_CHANGE, handleAssociatedEntityPropertyChange);
			unassociateForeignKey();
		}
		
		/**
		 * The property on the owner that defines the foreign key to load this association.
		 */
		public function get foreignKey():String
		{
			return options.foreignKey != null ? options.foreignKey : property + "Id";
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
			return null;
		}
		
		/**
		 * @inheritDoc
		 */
		override public function set object(value:*):void
		{
			if (object != null) unassociate(object);
			super.object = value;
			if (object != null) associate(object);
		}
	}
}