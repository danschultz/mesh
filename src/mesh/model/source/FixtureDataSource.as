package mesh.model.source
{
	import collections.HashMap;
	
	import flash.utils.setTimeout;
	
	import mesh.core.object.merge;
	import mesh.model.store.Data;
	import mesh.operations.Operation;

	/**
	 * A data source that is used for static or test data.
	 * 
	 * @author Dan Schultz
	 */
	public class FixtureDataSource extends DataSource
	{
		private var _fixtures:HashMap = new HashMap();
		
		private var _type:Class;
		private var _options:Object;
		
		/**
		 * Constructor.
		 * 
		 * @param type The type of records this data source is for.
		 * @param options A hash of options.
		 */
		public function FixtureDataSource(type:Class, options:Object = null)
		{
			super();
			_type = type;
			_options = merge({idField:"id", latency:0}, options);
		}
		
		/**
		 * Adds a fixture to this data source.
		 * 
		 * @param data The data to add.
		 */
		public function add(data:Object):void
		{
			_fixtures.put(data[_options.idField], data);
		}
		
		private function invoke(block:Function):void
		{
			if (_options.latency > 0) setTimeout(block, _options.latency);
			else block()
		}
		
		/**
		 * @inheritDoc
		 */
		override public function retrieve(recordType:Class, id:Object):Operation
		{
			if (recordType != _type) {
				throw new ArgumentError("Invalid record type.");
			}
			
			return new TimedOperation(_options.latency, function():Data
			{
				return new Data(_fixtures.grab(id), recordType);
			});
		}
		
		override public function retrieveAll(recordType:Class):Operation
		{
			if (recordType != _type) {
				throw new ArgumentError("Invalid record type.");
			}
			
			return new TimedOperation(_options.latency, function():Array
			{
				return _fixtures.values().map(function(fixture:Object, ...args):Data
				{
					return new Data(fixture, recordType);
				});
			});
		}
		
		override public function search(recordType:Class, params:Object):Operation
		{
			if (recordType != _type) {
				throw new ArgumentError("Invalid record type.");
			}
			
			return new TimedOperation(_options.latency, function():Array
			{
				var results:Array = _fixtures.values().filter(function(fixture:Object, ...args):Boolean
				{
					for (var property:String in params) {
						if (fixture[property] != params[property]) {
							return false;
						}
					}
					return true;
				});
				
				return results.map(function(fixture:Object, ...args):Data
				{
					return new Data(fixture, recordType);
				});
			});
		}
	}
}

import flash.utils.setTimeout;

import mesh.operations.MethodOperation;

class TimedOperation extends MethodOperation
{
	private var _timeout:Number;
	
	public function TimedOperation(timeout:Number, block:Function)
	{
		super(block);
		_timeout = timeout;
	}
	
	override protected function executeRequest():void
	{
		if (_timeout > 0) setTimeout(super.executeRequest, _timeout);
		else super.executeRequest();
	}
}