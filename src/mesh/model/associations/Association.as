package mesh.model.associations
{
	import flash.errors.IllegalOperationError;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.utils.Proxy;
	
	import mesh.core.inflection.humanize;
	import mesh.core.reflection.Type;
	import mesh.mesh_internal;
	import mesh.model.Record;
	import mesh.model.store.Store;
	
	import mx.events.PropertyChangeEvent;
	
	use namespace mesh_internal;
	
	/**
	 * An association class is a proxy object that contains the references to the objects in
	 * a relationship, where the <em>owner</em> represents the object hosting the association, 
	 * and the <em>object</em> is the actual associated object.
	 * 
	 * @author Dan Schultz
	 */
	public class Association extends Proxy implements IEventDispatcher
	{
		private var _dispatcher:EventDispatcher;
		
		/**
		 * Constructor.
		 * 
		 * @param owner The parent that owns the relationship.
		 * @param property The property name on the owner that association is mapped to.
		 * @param options The options for this association.
		 */
		public function Association(owner:Record, property:String, options:Object = null)
		{
			super();
			
			_dispatcher = new EventDispatcher(this);
			_owner = owner;
			_property = property;
			_options = options != null ? options : {};
			
			// Watch for assignments to the mapped property on the owner. If the property is reassigned,
			// then we'll need the association to wrap the new object.
			owner.addEventListener(PropertyChangeEvent.PROPERTY_CHANGE, handleOwnerPropertyChange);
		}
		
		/**
		 * Called by sub-classes when an record is added to an association.
		 * 
		 * @param record The record that was associated.
		 * @param revive Indicates if the record should be revived when associated.
		 */
		protected function associate(record:Record):void
		{
			store.records.insert(record);
			populateInverseRelationship(record, owner);
			markMasterAsDirty();
		}
		
		private function handleOwnerPropertyChange(event:PropertyChangeEvent):void
		{
			if (event.property is String && event.property.toString() == property) {
				object = event.newValue;
			}
		}
		
		/**
		 * Called when the owner has been inserted into the store, and the association can be
		 * initialized.
		 */
		mesh_internal function initialize():void
		{
			
		}
		
		private function markMasterAsDirty():void
		{
			if (isMaster) {
				owner.changeState(owner.state.dirty());
			}
		}
		
		private function populateInverseRelationship(record:Record, value:Record):void
		{
			if (inverse != null) {
				if (record.hasOwnProperty(inverse)) record[inverse] = value;
				else throw new IllegalOperationError("Inverse property '" + record.reflect.name + "." + inverse + "' does not exist.");
			}
		}
		
		/**
		 * Called when the owner has been synced with the data source.
		 */
		mesh_internal function synced():void
		{
			
		}
		
		/**
		 * @private
		 */
		public function toString():String
		{
			return humanize(reflect.className).toLowerCase() + " on " + owner.reflect.name + "." + property
		}
		
		/**
		 * Called by a sub-class when an record has been removed from an association.
		 * 
		 * @param record The record to unassociate.
		 */
		protected function unassociate(record:Record):void
		{
			populateInverseRelationship(record, null);
			markMasterAsDirty();
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
		
		private var _owner:Record;
		/**
		 * The instance of the parent owning this association.
		 */
		protected function get owner():Record
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
		
		/**
		 * The store that the owner belongs to.
		 */
		protected function get store():Store
		{
			return owner.store;
		}
		
		// Methods for IEventDispatcher
		
		/**
		 * @inheritDoc
		 */
		public function addEventListener(type:String, listener:Function, useCapture:Boolean = false, priority:int = 0, useWeakReference:Boolean = false):void
		{
			_dispatcher.addEventListener(type, listener, useCapture, priority, useWeakReference);
		}
		
		/**
		 * @inheritDoc
		 */
		public function dispatchEvent(event:Event):Boolean
		{
			return _dispatcher.dispatchEvent(event);
		}
		
		/**
		 * @inheritDoc
		 */
		public function hasEventListener(type:String):Boolean
		{
			return _dispatcher.hasEventListener(type);
		}
		
		/**
		 * @inheritDoc
		 */
		public function removeEventListener(type:String, listener:Function, useCapture:Boolean = false):void
		{
			_dispatcher.removeEventListener(type, listener, useCapture);
		}
		
		/**
		 * @inheritDoc
		 */
		public function willTrigger(type:String):Boolean
		{
			return _dispatcher.willTrigger(type);
		}
	}
}