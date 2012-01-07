package mesh.model
{
	import flash.errors.IllegalOperationError;
	
	import mesh.core.reflection.Type;

	/**
	 * The <code>Aggregates</code> class contains the logic for aggregating properties on an object. Aggregates 
	 * allow your models to group related sets of properties into value objects. This feature allows you to 
	 * express relationships such as a <em>Person is composed of an Address</em>. Each aggregate describes how 
	 * to construct a value object from an record's properties, and how value objects are turned back into values 
	 * on the record.
	 * 
	 * <p>
	 * Whenever an aggregated property on the record changes, the aggregate will also be updated.
	 * </p>
	 * 
	 * <p>
	 * <strong>Example:</strong> Defining an address aggregate for a person:
	 * 
	 * <listing version="3.0">
	 * public class Person extends Record
	 * {
	 * 	[Bindable] public var address:Address;
	 * 	[Bindable] public var street:String;
	 * 	[Bindable] public var city:String;
	 * 	
	 * 	public function Customer()
	 * 	{
	 * 		super();
	 * 		aggregate("address", Address, ["street","city"]);
	 * 	}
	 * }
	 * 
	 * public class Address
	 * {
	 * 	public function Address(street:String, city:String)
	 * 	{
	 * 		_street = street;
	 * 		_city = city;
	 * 	}
	 * 
	 * 	private var _street:String;
	 * 	public function get street():String 
	 * 	{
	 * 		return _street;
	 * 	}
	 * 
	 * 	private var _city:String;
	 * 	public function get city():String {
	 * 		return _city;
	 * 	}
	 * }
	 * </listing>
	 * </p>
	 * 
	 * @author Dan Schultz
	 */
	public class Aggregates
	{
		private var _host:Object;
		private var _propertyToAggregate:Object = {};
		
		/**
		 * Constructor.
		 * 
		 * @param host The object that contains the properties to aggregate.
		 */
		public function Aggregates(host:Object)
		{
			_host = host;
		}
		
		/**
		 * Defines an aggregated property on this object.
		 * 
		 * @param property The aggregate property.
		 * @param type The type of class.
		 * @param mappings The list of properties on the record to aggregate. The list must be in the same order
		 * 	as the argument's to the aggregate classes' constructor.
		 */
		public function add(property:String, type:Class, mappings:Array):void
		{
			if (_propertyToAggregate.hasOwnProperty(property)) {
				throw new IllegalOperationError(Type.reflect(_host).name + "." + property + " is already mapped to an aggregate.");
			}
			
			var aggregate:Aggregate = new Aggregate(_host, property, type, mappings);
			_propertyToAggregate[property] = aggregate;
			
			for (var key:String in aggregate.mappings) {
				_propertyToAggregate[key] = aggregate;
			}
		}
		
		/**
		 * The host object calls this method to update the aggregate mapped to a property.
		 * 
		 * @param property The property to update.
		 */
		public function changed(property:String):void
		{
			if (_propertyToAggregate.hasOwnProperty(property)) {
				_propertyToAggregate[property].changed(property);
			}
		}
	}
}

import mesh.core.reflection.newInstance;

class Aggregate
{
	/**
	 * Constructor.
	 * 
	 * @param record The host record.
	 * @param property The property on the record that the aggregate is mapped to.
	 * @param type The aggregate type class.
	 * @param mapping
	 */
	public function Aggregate(host:Object, property:String, type:Class, mappings:Array)
	{
		_host = host;
		_property = property;
		_type = type;
		
		for each (var mapping:String in mappings) {
			var keyValue:Array = mapping.split(":");
			
			if (keyValue.length == 1) {
				keyValue.push(keyValue[0]);
			}
			
			_mapSequence.push(keyValue[0]);
			_mappings[keyValue[0]] = keyValue[1];
		}
	}
	
	private var _changing:Boolean;
	public function changed(property:String):void
	{
		if (!_changing) {
			if (property == this.property) {
				updateProperties();
			} else {
				updateAggregate()
			}
		}
	}
	
	private function updateAggregate():void
	{
		var args:Array = [];
		for (var key:String in _mapSequence) {
			args.push(mappings[key]);
		}
		_host[property] = newInstance.apply(null, [type].concat(args));
	}
	
	private function updateProperties():void
	{
		for (var key:String in mappings) {
			_host[mappings[key]] = host[property][key];
		}
	}
	
	private var _host:Object;
	/**
	 * The host the aggregate.
	 */
	public function get host():Object
	{
		return _host;
	}
	
	private var _mapSequence:Array = [];
	private var _mappings:Object = {};
	public function get mappings():Object
	{
		return _mappings;
	}
	
	private var _property:String;
	/**
	 * The property on the record that the aggregate is mapped to.
	 */
	public function get property():String
	{
		return _property;
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