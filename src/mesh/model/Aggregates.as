package mesh.model
{
	import flash.errors.IllegalOperationError;
	
	import mesh.core.reflection.Type;

	public class Aggregates
	{
		private var _host:Object;
		private var _propertyToAggregate:Object = {};
		
		public function Aggregates(host:Object)
		{
			_host = host;
		}
		
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
	 * @param entity The host entity.
	 * @param property The property on the entity that the aggregate is mapped to.
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
	 * The property on the entity that the aggregate is mapped to.
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