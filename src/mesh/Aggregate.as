package mesh
{
	import mesh.core.reflection.newInstance;

	/**
	 * An aggregate represents a relationship that an entity has with a value object. It
	 * expresses relationships like <em>Person is composed of an Address.</em>  When an
	 * aggregate is defined on an entity, the value objects's properties will be accessible on
	 * the entity.
	 * 
	 * @author Dan Schultz
	 */
	public class Aggregate
	{
		private var _options:Object;
		
		private var _mappingOrder:Array = [];
		private var _mapping:Object = {};
		
		/**
		 * Constructor.
		 * 
		 * @param entity The host entity.
		 * @param property The property on the entity that the aggregate is mapped to.
		 * @param type The aggregate type class.
		 * @param constructor A function that generates a new value object.
		 * @param options
		 */
		public function Aggregate(entity:Class, property:String, type:Class, options:Object = null)
		{
			_entity = entity;
			_property = property;
			_type = type;
			_options = options;
			
			for each (var mapping:String in options.mapping) {
				var keyValue:Array = mapping.split(":");
				
				if (keyValue.length == 1) {
					keyValue.push(keyValue[0]);
				}
				
				if (options.prefix != null && options.prefix.length > 0) {
					keyValue[0] = options.prefix + keyValue[0].substr(0, 1).toUpperCase() + keyValue[0].substr(1);
				}
				
				_mappingOrder.push(keyValue[0]);
				_mapping[keyValue[0]] = keyValue[1];
			}
		}
		
		/**
		 * Checks if two aggregates are equal.
		 * 
		 * @param aggregate The aggregate to check.
		 * @return <code>true</code> if the aggregates are equal.
		 */
		public function equals(aggregate:Aggregate):Boolean
		{
			return aggregate != null && 
				   entity == aggregate.entity && 
				   property == aggregate.property;
		}
		
		public function getMappedProperty(entityProperty:String):String
		{
			return _mapping[entityProperty];
		}
		
		public function getValue(entity:Entity, entityProperty:String):*
		{
			var typeProperty:String = _mapping[entityProperty];
			var aggregate:Object = entity[property];
			return aggregate != null ? aggregate[typeProperty] : null;
		}
		
		/**
		 * @private
		 */
		public function hashCode():Object
		{
			return _property;
		}
		
		public function hasMappedProperty(property:String):Boolean
		{
			return _mapping.hasOwnProperty(property);
		}
		
		public function setValue(entity:Entity, entityProperty:String, value:*):void
		{
			entity[property] = newInstance.apply(null, [type].concat(_mappingOrder.map(function(item:String, index:int, array:Array):Object {
				if (item == entityProperty) {
					return value;
				}
				return getValue(entity, item);
			})));
		}
		
		private var _entity:Class;
		/**
		 * The entity the aggregate.
		 */
		public function get entity():Class
		{
			return _entity;
		}
		
		/**
		 * <code>true</code> if this aggregate has set the <em>bindable</em>.
		 */
		public function get isBindable():Boolean
		{
			if (_options.hasOwnProperty("bindable")) {
				if (_options.bindable is String) {
					_options.bindable = (_options.bindable.toLowerCase() == "true")
				}
				return _options.bindable;
			}
			return true;
		}
		
		/**
		 * The mappings defined on this aggregate.
		 */
		public function get mappings():Array
		{
			return _mappingOrder.concat();
		}
		
		private var _property:String;
		/**
		 * The property on the entity that the aggregate is mapped to.
		 */
		public function get property():String
		{
			return _property;
		}
		
		/**
		 * A list of all the properties related to this aggregate that will be included
		 * on the entity.
		 */
		public function get properties():Array
		{
			return mappings.concat(property);
		}
		
		private var _type:Class;
		/**
		 * The aggregate class.
		 */
		public function get type():Class
		{
			return _type;
		}
	}
}