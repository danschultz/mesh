package mesh.model.associations
{
	import collections.HashSet;
	
	import flash.errors.IllegalOperationError;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	
	import mesh.core.inflection.humanize;
	import mesh.core.reflection.Type;
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
		private static const UNINITIALIZED:int = 0;
		private static const LOADING:int = 1;
		private static const LOADED:int = 2;
		
		private var _state:int = UNINITIALIZED;
		
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
		protected function associate(entity:Entity):void
		{
			_entities.add(entity);
			populateInverseRelationship(entity);
		}
		
		private function changeState(state:int):void
		{
			if (_state != state) {
				_state = state;
				dispatchEvent(new Event("stateChange"));
			}
		}
		
		private function handleOwnerPropertyChange(event:PropertyChangeEvent):void
		{
			if (event.property is String && event.property.toString() == property) {
				object = event.newValue;
			}
		}
		
		/**
		 * Used internally by the entity to initialize the association with its data.
		 */
		public function initialize():void
		{
			object = owner[property];
		}
		
		/**
		 * Loads the data for this association. If this is a non-lazy association, then nothing happens.
		 */
		public function load():void
		{
			changeState(LOADING);
			performLoad();
		}
		
		/**
		 * Called by sub-classes to indicate that the data for the association has been loaded
		 * from the store.
		 */
		protected function loaded():void
		{
			changeState(LOADED);
		}
		
		/**
		 * Called by <code>load()</code> to load the data for the association.
		 */
		protected function performLoad():void
		{
			
		}
		
		private function populateInverseRelationship(entity:Entity):void
		{
			if (inverse != null) {
				if (entity.hasOwnProperty(inverse)) entity[inverse] = owner;
				else throw new IllegalOperationError("Inverse property '" + entity.reflect.name + "." + inverse + "' does not exist.");
			}
		}
		
		private function setBindableReadOnlyProperty(property:String, setter:Function):void
		{
			var oldValue:* = this[property];
			setter();
			dispatchEvent(PropertyChangeEvent.createUpdateEvent(this, property, oldValue, this[property]));
		}
		
		/**
		 * @private
		 */
		override public function toString():String
		{
			return humanize(reflect.className).toLowerCase() + " on " + owner.reflect.name + "." + property
		}
		
		/**
		 * Called by a sub-class when an entity has been removed from an association.
		 * 
		 * @param entity The entity to unassociate.
		 */
		protected function unassociate(entity:Entity):void
		{
			_entities.remove(entity);
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
		
		[Bindable(event="stateChange")]
		/**
		 * Indicates if the data for this association has been loaded.
		 */
		public function get isLoaded():Boolean
		{
			return _state == LOADED;
		}
		
		[Bindable(event="stateChange")]
		/**
		 * Indicates if the data for this association is loading.
		 */
		public function get isLoading():Boolean
		{
			return _state == LOADING;
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