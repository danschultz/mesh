package mesh.model.source
{
	import flash.utils.Dictionary;
	import flash.utils.setTimeout;
	
	import mesh.core.object.merge;
	import mesh.model.Entity;
	import mesh.model.store.Commit;
	import mesh.model.store.Store;
	
	import mx.rpc.Fault;

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
		override public function create(commit:Commit, entity:Entity):void
		{
			var data:Object = serialize([entity])[0];
			setTimeout(function():void
			{
				if (!entity.isNew) {
					update(commit, entity);
				} else {
					entity.id = ++_idCounter;
					_fixtures[entity.id] = data;
					commit.completed([entity]);
				}
			}, latency);
		}
		
		/**
		 * @inheritDoc
		 */
		override public function destroy(commit:Commit, entity:Entity):void
		{
			var data:Object = serialize([entity])[0];
			setTimeout(function():void
			{
				if (_fixtures[data.id] != null) {
					delete _fixtures[data.id];
					commit.completed([entity]);
				} else {
					commit.failed([entity], new Fault("", "Entity '" + entity.reflect.name + "' with ID=" + data.id + " does not exist"));
				}
			}, latency);
		}
		
		/**
		 * @inheritDoc
		 */
		override public function retrieve(store:Store, entity:Entity):void
		{
			var data:Object = serialize([entity])[0];
			setTimeout(function():void
			{
				if (_fixtures[data.id] != null) {
					//entity.deserialize(_fixtures[data.id]);
				} else {
					entity.errored();
				}
			}, latency);
		}
		
		/**
		 * @inheritDoc
		 */
		override public function update(commit:Commit, entity:Entity):void
		{
			var data:Object = serialize([entity])[0];
			setTimeout(function():void
			{
				if (_fixtures[data.id] == null) {
					commit.failed([entity], new Fault("", "Entity '" + entity.reflect.name + "' with ID=" + data.id + " does not exist"));
				} else {
					_fixtures[data.id] = data;
					commit.completed([entity]);
				}
			}, latency);
		}
		
		private function get latency():Number
		{
			return _options.latency;
		}
	}
}