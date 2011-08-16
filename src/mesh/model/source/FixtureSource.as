package mesh.model.source
{
	import flash.errors.IllegalOperationError;
	import flash.utils.Dictionary;
	import flash.utils.setTimeout;
	
	import mesh.core.object.merge;
	import mesh.model.Entity;
	import mesh.model.store.Store;

	public class FixtureSource extends Source
	{
		private var _fixtures:Dictionary = new Dictionary();
		private var _idCounter:int;
		private var _options:Object;
		
		/**
		 * Constructor.
		 * 
		 * @param options The options for this source.
		 */
		public function FixtureSource(options:Object = null)
		{
			super();
			_options = merge({latency:250}, options);
		}
		
		/**
		 * @inheritDoc
		 */
		override public function create(store:Store, entity:Entity):void
		{
			entity.busy();
			
			setTimeout(function():void
			{
				if (!entity.isNew) {
					update(store, entity);
				} else {
					synced([entity], [++_idCounter]);
				}
			}, latency);
		}
		
		/**
		 * @inheritDoc
		 */
		override public function destroy(store:Store, entity:Entity):void
		{
			entity.busy();
			
			var data:Object = entity.serialize();
			setTimeout(function():void
			{
				if (_fixtures[data.id] != null) {
					delete _fixtures[data.id];
					synced([entity]);
				} else {
					errored([entity]);
				}
			}, latency);
		}
		
		/**
		 * @inheritDoc
		 */
		override public function retrieve(store:Store, entity:Entity):void
		{
			entity.busy();
			
			var data:Object = entity.serialize();
			setTimeout(function():void
			{
				if (_fixtures[data.id] != null) {
					entity.deserialize(_fixtures[data.id]);
					synced([entity]);
				} else {
					entity.errored();
				}
			}, latency);
		}
		
		/**
		 * @inheritDoc
		 */
		override public function update(store:Store, entity:Entity):void
		{
			entity.busy();
			
			var data:Object = entity.serialize();
			setTimeout(function():void
			{
				if (data.id != null && data.id > 0) {
					_fixtures[data.id] = data;
					synced([entity]);
				} else {
					errored([entity]);
				}
			}, latency);
		}
		
		private function get latency():Number
		{
			return _options.latency;
		}
	}
}