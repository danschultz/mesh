package mesh.model.source
{
	import collections.HashMap;
	
	import flash.utils.setTimeout;
	
	import mesh.core.object.merge;
	import mesh.model.store.Data;
	import mesh.model.store.RecordRequest;

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
			else block();
		}
		
		/**
		 * @inheritDoc
		 */
		override public function retrieve(request:RecordRequest):void
		{
			if (request.record.reflect.clazz != _type) {
				throw new ArgumentError("Invalid record type.");
			}
			
			invoke(function():void
			{
				request.result( new Data(_fixtures.grab(request.record.id), _type) );
			});
		}
	}
}