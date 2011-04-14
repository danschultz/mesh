package mesh
{
	import collections.Collection;
	
	/**
	 * A class that holds an object's old values.
	 * 
	 * @author Dan Schultz
	 */
	public class Changes
	{
		private var _host:Object;
		private var _oldValues:Object = {};
		
		/**
		 * Constructor.
		 * 
		 * @param host The object to hold changes for.
		 */
		public function Changes(host:Object)
		{
			_host = host;
		}
		
		/**
		 * Marks the given property as being changed on the host.
		 * 
		 * @param property The property that has changed.
		 * @param oldValue The property's old value.
		 * @param newValue The property's new value.
		 */
		public function changed(property:String, oldValue:Object, newValue:Object):void
		{
			if (!_oldValues.hasOwnProperty(property)) {
				_oldValues[property] = oldValue;
			}
		}
		
		/**
		 * Removes all original values.
		 */
		public function clear():void
		{
			_oldValues = {};
		}
		
		/**
		 * Returns the current value for the given property on the host.
		 * 
		 * @param property The property name to retrieve.
		 * @return The property's current value.
		 */
		public function currentValue(property:String):*
		{
			return _host[property];
		}
		
		/**
		 * Performs a check to see if the given property has changed. This method will
		 * first check based on the identity of the changed values. If this fails, it 
		 * will use the <code>equals()</code> method defined on the value, if the method
		 * exists.
		 * 
		 * @param property The property to check.
		 * @return <code>true</code> if the property has changed.
		 */
		public function hasPropertyChanged(property:String):Boolean
		{
			if (_oldValues.hasOwnProperty(property)) {
				return !Collection.areElementsEqual(oldValue(property), currentValue(property));
			}
			return false;
		}
		
		/**
		 * Returns the original value for the given property. If a value does not exist for the
		 * property, <code>undefined</code> is returned.
		 * 
		 * @param property The property to get the original value for.
		 * @return The properties original value, or <code>undefined</code> if no value exists.
		 */
		public function oldValue(property:String):*
		{
			return _oldValues.hasOwnProperty(property) ? _oldValues[property] : currentValue(property);
		}
		
		/**
		 * Sets all properties on the host back to their original values.
		 */
		public function revert():void
		{
			for (var property:String in _oldValues) {
				_host[property] = oldValue(property);
			}
			clear();
		}
		
		/**
		 * <code>true</code> if the values of the properties have changed on the host.
		 */
		public function get hasChanges():Boolean
		{
			for (var property:String in _oldValues) {
				if (hasPropertyChanged(property)) {
					return true;
				}
			}
			return false;
		}
	}
}