package mesh.core.serialization
{
	import mesh.core.object.merge;
	import mesh.core.reflection.Property;
	import mesh.core.reflection.reflect;
	
	import mx.utils.ObjectUtil;

	/**
	 * The <code>Serializer</code> class defines a process for serializing an object into
	 * any arbitrary format. The serializer uses a delegate for determining the serialization 
	 * format.
	 * 
	 * @author Dan Schultz
	 */
	public class Serializer
	{
		private var _cache:MarshalCache = new MarshalCache();
		
		/**
		 * Constructor.
		 * 
		 * <p>
		 * You may pass an optional options hash to configure the serializer.
		 * 
		 * <ul>
		 * <li><code>includeDynamic:Boolean</code> - Indicates if dynamic properties should be 
		 * 	included in the serialization. (default=<code>false</code>)</li>
		 * </ul>
		 * </p>
		 * 
		 * @param options A hash of options for this serializer.
		 */
		public function Serializer(options:Object = null)
		{
			_options = merge({includeDynamic:false}, options);
		}
		
		/**
		 * Serializes an object using the given delegate. If the delegate is empty, then the 
		 * default one given to the serializer's constructor will be used.
		 * 
		 * @param object The object to serialize.
		 * @param delegate The delegate that will write the serialized data.
		 * @return The marshalled object.
		 */
		public function marshal(object:Object, delegate:ISerializerDelegate):*
		{
			if (!_cache.isCached(object)) {
				_cache.cache(object, delegate.serialized);
				
				for each (var property:String in properties(object)) {
					marshalProperty(object, property, object[property], delegate);
				}
			}
			return _cache.fetch(object);
		}
		
		private function marshalProperty(object:Object, property:String, value:Object, delegate:ISerializerDelegate):void
		{
			if (ObjectUtil.isSimple(value)) {
				delegate.writeProperty(property, value);
			} else {
				delegate.writeProperty(property, marshal(value, delegate.node()));
			}
		}
		
		/**
		 * Called during the marshaling of an object to return each property that must be marshaled.
		 * 
		 * @param object The object to get the properties for.
		 * @return A list of property names.
		 */
		protected function properties(object:Object):Array
		{
			return ((includeDynamic ? findDynamic(object) : []) as Array).concat(findFixed(object));
		}
		
		/**
		 * Finds the dynamic properties belonging to an object.
		 * 
		 * @param object The object to get the dynamic properties from.
		 * @return A list of property names.
		 */
		protected function findDynamic(object:Object):Array
		{
			var properties:Array = [];
			for (var property:String in object) {
				properties.push(property);
			}
			return properties;
		}
		
		/**
		 * Finds the fixed properties belonging to an object.
		 * 
		 * @param object The object to get the fixed proeprties for.
		 * @return A list of property names.
		 */
		protected function findFixed(object:Object):Array
		{
			var properties:Array = [];
			for (var property:Property in reflect(object).properties) {
				if (!property.isStatic && property.isReadable) {
					properties.push(property.name);
				}
			}
			return properties;
		}
		
		/**
		 * Indicates if dynamic properties should be included when marshaling.
		 */
		protected function get includeDynamic():Boolean
		{
			return options.includeDynamic;
		}
		
		private var _options:Object;
		/**
		 * The options hash for the serializer.
		 */
		protected function get options():Object
		{
			return _options;
		}
	}
}

import flash.utils.Dictionary;

class MarshalCache
{
	private var _cache:Dictionary;
	private var _flags:Dictionary;
	
	public function MarshalCache()
	{
		purge();
	}
	
	public function cache(object:Object, value:*):void
	{
		_cache[object] = value;
		_flags[object] = true;
	}
	
	public function fetch(object:Object):*
	{
		return _cache[object];
	}
	
	public function purge():void
	{
		_cache = new Dictionary();
		_flags = new Dictionary();
	}
	
	public function isCached(object:Object):Boolean
	{
		return _flags[object] == true;
	}
}