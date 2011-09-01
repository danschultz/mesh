package mesh.model.associations
{
	import collections.HashSet;
	
	import flash.errors.IllegalOperationError;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	
	import mesh.core.inflection.humanize;
	import mesh.core.reflection.Type;
	import mesh.model.Entity;
	import mesh.model.load.LoadEvent;
	import mesh.model.load.LoadFailedEvent;
	import mesh.model.load.LoadHelper;
	import mesh.model.load.LoadSuccessEvent;
	import mesh.model.source.SourceFault;
	
	import mx.events.PropertyChangeEvent;
	
	/**
	 * Dispatched when the result list starts loading its content.
	 */
	[Event(name="loading", type="mesh.model.load.LoadEvent")]
	
	/**
	 * Dispatched when the result list has successfully loaded its content.
	 */
	[Event(name="success", type="mesh.model.load.LoadSuccessEvent")]
	
	/**
	 * Dispatched when the result list has failed to load its content.
	 */
	[Event(name="failed", type="mesh.model.load.LoadFailedEvent")]
	
	/**
	 * An association class is a proxy object that contains the references to the objects in
	 * a relationship, where the <em>owner</em> represents the object hosting the association, 
	 * and the <em>object</em> is the actual associated object.
	 * 
	 * @author Dan Schultz
	 */
	public class Association extends EventDispatcher
	{
		private var _helper:LoadHelper;
		
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
			
			_helper = new LoadHelper(this);
			
			// Watch for assignments to the mapped property on the owner. If the property is reassigned,
			// then we'll need the association to wrap the new object.
			owner.addEventListener(PropertyChangeEvent.PROPERTY_CHANGE, handleOwnerPropertyChange);
			
			addEventListener(LoadEvent.LOADING, function(event:LoadEvent):void
			{
				executeLoad();
			});
		}
		
		/**
		 * Called by sub-classes when an entity is added to an association.
		 * 
		 * @param entity The entity that was associated.
		 * @param revive Indicates if the entity should be revived when associated.
		 */
		protected function associate(entity:Entity):void
		{
			if (owner.store && entity.store == null) owner.store.add(entity);
			_entities.add(entity);
			populateInverseRelationship(entity);
		}
		
		private function cleanupLoad():void
		{
			_loadable = null;
		}
		
		/**
		 * Called by sub-classes if the association's data failed to load.
		 * 
		 * @param fault The reason for the failure.
		 */
		protected function failed(fault:SourceFault):void
		{
			_helper.failed(fault);
			cleanupLoad();
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
			var data:Object = owner[property];
			if (!isLazy) {
				loaded(data);
			} else {
				object = data;
			}
		}
		
		/**
		 * Loads the data for this association. If this is a non-lazy association, then nothing happens.
		 */
		public function load():void
		{
			_helper.load();
		}
		
		/**
		 * Called when the association's data needs to be loaded. Sub-classes must override this
		 * method in order to load the association's data.
		 */
		protected function executeLoad():void
		{
			
		}
		
		private var _loadable:IEventDispatcher;
		/**
		 * Called when the association needs to load its data. Sub-classes must override this method in
		 * order to load the data.
		 */
		protected function wrapLoad(loadable:IEventDispatcher):void
		{
			_loadable = loadable;
			_loadable.addEventListener(LoadSuccessEvent.SUCCESS, function(event:LoadSuccessEvent):void
			{
				loaded(_loadable);
			}, false, 0, true);
			_loadable.addEventListener(LoadFailedEvent.FAILED, function(event:LoadFailedEvent):void
			{
				failed(event.fault);
			}, false, 0, true);
		}
		
		/**
		 * Called by sub-classes when the data for this association has been loaded. The loaded data will
		 * replace any data on the associated property.
		 * 
		 * @param data The loaded data.
		 */
		protected function loaded(data:Object):void
		{
			owner[property] = data;
			object = data;
			_helper.loaded(data);
			cleanupLoad();
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
		 * Indicates that the data has not been loaded for this association when the owner was loaded.
		 */
		public function get isLazy():Boolean
		{
			return options.isLazy || options.lazy;
		}
		
		/**
		 * Indicates if the data for this association has been loaded.
		 */
		public function get isLoaded():Boolean
		{
			return _helper.isLoaded;
		}
		
		/**
		 * Indicates if the association is loading its data.
		 */
		public function get isLoading():Boolean
		{
			return _helper.isLoading;
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