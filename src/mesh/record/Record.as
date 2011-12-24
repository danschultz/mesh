package mesh.record
{
	import flash.events.EventDispatcher;
	
	import mesh.core.reflection.Type;
	import mesh.model.Changes;
	import mesh.store.Data;
	
	import mx.events.PropertyChangeEvent;
	
	/**
	 * A <code>Record</code> wraps data belonging to the store.
	 * 
	 * @author Dan Schultz
	 */
	public class Record extends EventDispatcher
	{
		/**
		 * Constructor.
		 */
		public function Record()
		{
			super();
			addEventListener(PropertyChangeEvent.PROPERTY_CHANGE, handlePropertyChange);
		}
		
		private function handlePropertyChange(event:PropertyChangeEvent):void
		{
			propertyChanged(event.property.toString(), event.oldValue, event.newValue);
		}
		
		/**
		 * Marks a property on the entity as being dirty. This method allows sub-classes to manually 
		 * manage when a property changes.
		 * 
		 * @param property The property that was changed.
		 * @param oldValue The property's old value.
		 * @param newValue The property's new value.
		 */
		protected function propertyChanged(property:String, oldValue:Object, newValue:Object):void
		{
			changes.changed(property, oldValue, newValue);
		}
		
		private var _changes:Changes;
		/**
		 * @copy Changes
		 */
		public function get changes():Changes
		{
			if (_changes == null) {
				_changes = new Changes(this);
			}
			return _changes;
		}
		
		private var _data:Data;
		/**
		 * The data from the store that the record is wrapping.
		 */
		public function get data():Data
		{
			return _data;
		}
		public function set data(value:Data):void
		{
			_data = value;
		}
		
		private var _reflect:Type;
		/**
		 * A reflection that contains the properties, methods and metadata defined on this
		 * entity.
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