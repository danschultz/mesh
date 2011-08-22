package mesh.model
{
	import collections.Collection;
	
	import flash.utils.IDataInput;
	import flash.utils.IDataOutput;
	import flash.utils.IExternalizable;
	
	[RemoteClass(alias="mesh.model.Changes")]
	
	/**
	 * The <code>Changes</code> class represents a storage container for values that have
	 * changed on an instance of an <code>Entity</code>.
	 * 
	 * @author Dan Schultz
	 */
	public class Changes implements IExternalizable
	{
		private var _host:Object;
		private var _oldValues:Object = {};
		
		/**
		 * Constructor.
		 * 
		 * @param host The object to hold changes for.
		 */
		public function Changes(host:Object = null)
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
		 * Either clears all recorded changes, or the changes recorded for the given property.
		 * 
		 * @param property The property to clear. If <code>null</code>, all changes are cleared.
		 */
		public function clear(property:String = null):void
		{
			if (property != null) {
				delete _oldValues[property];
			} else {
				_oldValues = {};
			}
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
		public function hasChanged(property:String):Boolean
		{
			if (_oldValues.hasOwnProperty(property)) {
				return !Collection.areElementsEqual(whatWas(property), whatIs(property));
			}
			return false;
		}
		
		/**
		 * @inheritDoc
		 */
		public function readExternal(input:IDataInput):void
		{
			_host = input.readObject();
			_oldValues = input.readObject();
		}
		
		/**
		 * Sets all properties on the host back to their original values.
		 */
		public function revert():void
		{
			for (var property:String in _oldValues) {
				_host[property] = whatWas(property);
			}
			clear();
		}
		
		/**
		 * Returns the current value for the given property on the host.
		 * 
		 * @param property The property name to retrieve.
		 * @return The property's current value.
		 */
		public function whatIs(property:String):*
		{
			return _host[property];
		}
		
		/**
		 * Returns the original value for the given property. If a value does not exist for the
		 * property, <code>undefined</code> is returned.
		 * 
		 * @param property The property to get the original value for.
		 * @return The properties original value, or <code>undefined</code> if no value exists.
		 */
		public function whatWas(property:String):*
		{
			return _oldValues.hasOwnProperty(property) ? _oldValues[property] : whatIs(property);
		}
		
		/**
		 * @inheritDoc
		 */
		public function writeExternal(output:IDataOutput):void
		{
			output.writeObject(_host);
			output.writeObject(_oldValues);
		}
		
		/**
		 * <code>true</code> if the values of the properties have changed on the host.
		 */
		public function get hasChanges():Boolean
		{
			for (var property:String in _oldValues) {
				if (hasChanged(property)) {
					return true;
				}
			}
			return false;
		}
	}
}