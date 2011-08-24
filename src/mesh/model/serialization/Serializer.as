package mesh.model.serialization
{
	import mesh.core.reflection.Property;
	import mesh.core.reflection.Type;
	import mesh.core.reflection.reflect;

	/**
	 * The <code>Serializer</code> class is used by the <code>Entity</code> to serialize its properties 
	 * into a hash. By default, this serializer will only serialize properties on an object that are 
	 * considered readable leaf nodes. These include: booleans, numbers and strings. You can do nested 
	 * levels of serialization by supplying the <code>includes</code> option.
	 * 
	 * <p>
	 * An options hash can be given to the serializer to modify its behavior. These options include:
	 * 
	 * <ul>
	 * <li><code>only:Array</code> - A list of leaf node properties to serialize.</li>
	 * <li><code>exclude:Array</code> - A list of leaf node properties to exclude from serializing.</li>
	 * <li><code>includes:Object</code> - A hash of association nodes to serialize. You can map each
	 * 	association to additional hashes of these options.</li>
	 * </ul>
	 * </p>
	 * 
	 * @author Dan Schultz
	 */
	public class Serializer
	{
		private var _object:Object;
		private var _options:Object;
		
		/**
		 * Constructor.
		 * 
		 * @param object The object to serialize.
		 * @param options An options hash to configure the serializer.
		 */
		public function Serializer(object:Object, options:Object = null)
		{
			_object = object;
			_options = options == null ? {} : options;
		}
		
		/**
		 * Serializes the object into a hash.
		 * 
		 * @return A hash of the serialized properties.
		 */
		public function serialize():*
		{
			var serialized:Object = {};
			
			// Serialize the defined properties.
			var reflection:Type = reflect(_object);
			for each (var property:String in properties()) {
				if (isImplicitLeaf(property) || isExplicitLeaf(reflection.property(property))) {
					serialized[property] = leafValue(property);
				}
			}
			
			// Serialize the associated includes.
			for (var association:String in includes) {
				serialized[association] = nodeValue(association, includes[association] is Boolean ? null : includes[association]);
			}
			
			return serialized;
		}
		
		private static const LEAF_TYPES:Array = [int, Number, uint, String, Date, Boolean];
		private function isExplicitLeaf(property:Property):Boolean
		{
			return property != null && LEAF_TYPES.some(function(type:Class, ...args):Boolean
			{
				try {
					return property.type.isA(type);
				} catch (e:Error) {
					
				}
				return false;
			});
		}
		
		private function isImplicitLeaf(property:String):Boolean
		{
			var value:Object = _object[property];
			switch (typeof value) {
				case "number":
				case "boolean":
				case "string":
					return true;
				case "object":
					return value is Date;
			}
			return false;
		}
		
		private function leafValue(property:String):*
		{
			return _object[property];
		}
		
		private function nodeValue(property:String, options:Object):*
		{
			var value:* = _object[property];
			
			// Attempt to simply the value to an array if possible.
			if (value != null && value.hasOwnProperty("toArray")) {
				value = value.toArray();
			}
			
			// The object is iterable, so serialize each of its children.
			if (value is Array) {
				value = value.map(function(object:Object, ...args):Object
				{
					if (object != null && object.hasOwnProperty("serialize")) {
						return object.serialize(options);
					}
					return new Serializer(object, options).serialize();
				});
			}
			// The object isn't iterable, so serialize it.
			else {
				value = value != null ? new Serializer(value, options).serialize() : value;
			}
			
			return value;
		}
		
		/**
		 * Aggregates the properties to serialize on the object.
		 */
		protected function properties():Array
		{
			var properties:Array = [];
			
			// Add all defined readable properties
			for each (var property:Property in reflect(_object).properties) {
				if (isSerializable(property)) {
					properties.push(property.name);
				}
			}
			
			return properties;
		}
		
		private function isSerializable(property:Property):Boolean
		{
			return (only == null || only.indexOf(property.name) != -1) &&
				   (exclude == null || exclude.indexOf(property.name) == -1) &&
				   (property.isReadable && !property.isStatic && !property.isConstant);
		}
		
		private function get only():Array
		{
			return _options.only;
		}
		
		private function get exclude():Array
		{
			return _options.exclude == null ? _options.excludes : _options.exclude;
		}
		
		private function get includes():Object
		{
			return _options.includes != null ? _options.includes : {};
		}
	}
}