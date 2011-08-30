package mesh.model.associations
{
	import collections.HashSet;
	
	import flash.errors.IllegalOperationError;
	import flash.events.EventDispatcher;
	
	import mesh.core.inflection.humanize;
	import mesh.core.reflection.Type;
	import mesh.core.state.StateEvent;
	import mesh.model.Entity;
	
	import mx.events.PropertyChangeEvent;
	
	/**
	 * An association class is a proxy object that contains the references to the objects in
	 * a relationship, where the <em>owner</em> represents the object hosting the association, 
	 * and the <em>object</em> is the actual associated object.
	 * 
	 * @author Dan Schultz
	 */
	public class Association extends EventDispatcher
	{
		/**
		 * Constructor.
		 * 
		 * @param owner The parent that owns the relationship.
		 * @param property The property name on the owner that association is mapped to.
		 * @param options The options for this association.
		 */
		public function Association(owner:Entity, property:String, options:Object = null)
		{
			super();
			_owner = owner;
			_property = property;
			_options = options != null ? options : {};
			
			// Watch for assignments to the mapped property on the owner. If the property is reassigned,
			// then we'll need the association to wrap the new object.
			owner.addEventListener(PropertyChangeEvent.PROPERTY_CHANGE, handleOwnerPropertyChange);
		}
		
		/**
		 * Called by sub-classes when an entity is added to an association.
		 * 
		 * @param entity The entity that was associated.
		 * @param revive Indicates if the entity should be revived when associated.
		 */
		protected function associate(entity:Entity, revive:Boolean):void
		{
			if (owner.store && entity.store == null) owner.store.add(entity);
			
			entity.addEventListener(StateEvent.ENTER, handleEntityStatusChange);
			if (revive) entity.revive();
			
			_entities.add(entity);
			populateInverseRelationship(entity);
		}
		
		private function handleEntityStatusChange(event:StateEvent):void
		{
			var entity:Entity = Entity( event.target );
			
			if (_entities.contains(entity)) {
				if (entity.status.isDestroyed) {
					entityDestroyed(entity);
				} else {
					entityRevived(entity);
				}
			}
		}
		
		/**
		 * Called when the entity's status changes from a destroyed to non-destroyed state. This allows
		 * the association to add the entity back to its host.
		 * 
		 * @param entity The entity that changed.
		 */
		protected function entityRevived(entity:Entity):void
		{
			
		}
		
		/**
		 * Called when the entity's status changes from a non-destroyed state to a destroyed state. This
		 * allows the association to remove the entity from its host.
		 * 
		 * @param entity The entity that changed.
		 */
		protected function entityDestroyed(entity:Entity):void
		{
			
		}
		
		private function handleOwnerPropertyChange(event:PropertyChangeEvent):void
		{
			if (event.property is String && event.property.toString() == property) {
				object = event.newValue;
			}
		}
		
		private function populateInverseRelationship(entity:Entity):void
		{
			if (inverse != null) {
				if (entity.hasOwnProperty(inverse)) entity[inverse] = owner;
				else throw new IllegalOperationError("Inverse property '" + entity.reflect.name + "." + inverse + "' does not exist.");
			}
		}
		
		/**
		 * Changes the state of the object for this association back to what it was at the last save.
		 */
		public function revert():void
		{
			
		}
		
		/**
		 * @private
		 */
		override public function toString():String
		{
			return humanize(reflect.className).toLowerCase();
		}
		
		/**
		 * Called by a sub-class when an entity has been removed from an association.
		 * 
		 * @param entity The entity to unassociate.
		 */
		protected function unassociate(entity:Entity):void
		{
			entity.removeEventListener(StateEvent.ENTER, handleEntityStatusChange);
			_entities.remove(entity);
		}
		
		/**
		 * The set of entities belonging to this association that are dependent on the owner being 
		 * committed first.
		 */
		public function get dependents():Array
		{
			return isMaster && owner.status.isNew ? entities : [];
		}
		
		private var _entities:HashSet = new HashSet();
		/**
		 * The set of entities belonging to this association.
		 */
		public function get entities():Array
		{
			return _entities.toArray();
		}
		
		/**
		 * The property on each associated object that maps back to the owner of the association.
		 */
		public function get inverse():String
		{
			return options.inverse;
		}
		
		/**
		 * Indicates that this side of the association is the parent.
		 */
		public function get isMaster():Boolean
		{
			return options.isMaster;
		}
		
		private var _object:*;
		/**
		 * The data assigned to this association.
		 */
		public function get object():*
		{
			return _object;
		}
		public function set object(value:*):void
		{
			_object = value;
		}
		
		private var _options:Object;
		/**
		 * The options defined for this association.
		 */
		protected function get options():Object
		{
			return _options;
		}
		
		private var _owner:Entity;
		/**
		 * The instance of the parent owning this association.
		 */
		protected function get owner():Entity
		{
			return _owner;
		}
		
		private var _property:String;
		/**
		 * The property name on the owner that this association is mapped to.
		 */
		public function get property():String
		{
			return _property;
		}
		
		private var _reflect:Type;
		/**
		 * A reflection on this object.
		 */
		public function get reflect():Type
		{
			if (_reflect == null) {
				_reflect = Type.reflect(this);
			}
			return _reflect;
		}
	}
}