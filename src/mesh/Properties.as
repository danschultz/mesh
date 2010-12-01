package mesh
{
	import flash.utils.Proxy;
	import flash.utils.flash_proxy;

	/**
	 * A class that tracks property changes that happen to an object.
	 * 
	 * @author Dan Schultz
	 */
	public class Properties extends Proxy
	{
		private var _host:Object;
		
		private var _oldValues:Object = {};
		private var _currentValues:Object = {};
		
		/**
		 * Constructor.
		 * 
		 * @param host The object that is being tracked.
		 */
		public function Properties(host:Object)
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
			_currentValues[property] = newValue;
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
				var oldValue:Object = _oldValues[property];
				var newValue:Object = _currentValues[property];
				
				if (oldValue === newValue) {
					return false;
				}
				
				if (oldValue != null && newValue != null && oldValue.hasOwnProperty("equals") && newValue.hasOwnProperty("equals")) {
					try {
						return !oldValue.equals(newValue);
					} catch (e:Error) {
						
					}
				}
				
				return true;
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
		public function oldValueOf(property:String):*
		{
			return _oldValues[property];
		}
		
		/**
		 * Sets all properties on the host back to their original values.
		 */
		public function revert():void
		{
			for (var property:String in _oldValues) {
				_host[property] = _oldValues[property];
			}
			reset();
		}
		
		public function reset():void
		{
			_oldValues = {};
		}
		
		/**
		 * <code>true</code> if the values of the properties have changed on the host.
		 */
		public function get hasChanges():Boolean
		{
			for (var property:String in _currentValues) {
				if (hasPropertyChanged(property)) {
					return true;
				}
			}
			return false;
		}
		
		/**
		 * @inheritDoc
		 */
		override flash_proxy function getProperty(name:*):*
		{
			return _currentValues[name];
		}
		
		/**
		 * @inheritDoc
		 */
		override flash_proxy function hasProperty(name:*):Boolean
		{
			return flash_proxy::getProperty(name) !== undefined;
		}
		
		/**
		 * @inheritDoc
		 */
		override flash_proxy function setProperty(name:*, value:*):void
		{
			changed(name, _host[name], value);
		}
	}
}