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
		private var _entityType:Class;
		
		/**
		 * Constructor.
		 * 
		 * @param entityType The type of entity that this fixture is for.
		 * @param options The options for this source.
		 */
		public function FixtureSource(entityType:Class, options:Object = null)
		{
			super();
			_entityType = entityType;
			_options = merge({latency:250}, options);
		}
		
		private function invoke(block:Function):void
		{
			if (latency > 0) setTimeout(block, latency);
			else block();
		}
		
		/**
		 * @inheritDoc
		 */
		override public function create(commit:Commit, entity:Entity):void
		{
			var data:Object = serialize([entity])[0];
			invoke(function():void
			{
				if (!entity.isNew) {
					update(commit, entity);
				} else {
					data.id = ++_idCounter;
					_fixtures[data.id] = data;
					commit.saved([entity], [{id:data.id}]);
				}
			});
		}
		
		/**
		 * @inheritDoc
		 */
		override public function destroy(commit:Commit, entity:Entity):void
		{
			var data:Object = serialize([entity])[0];
			invoke(function():void
			{
				if (_fixtures[data.id] != null) {
					delete _fixtures[data.id];
					commit.destroyed([entity]);
				} else {
					commit.failed([entity], new Fault("", "Entity '" + entity.reflect.name + "' with ID=" + data.id + " does not exist"));
				}
			});
		}
		
		/**
		 * @inheritDoc
		 */
		override public function retrieve(store:Store, entity:Entity):void
		{
			var data:Object = serialize([entity])[0];
			invoke(function():void
			{
				if (_fixtures[data.id] != null) {
					entity.fromObject(_fixtures[data.id]);
				} else {
					entity.errored();
				}
			});
		}
		
		/**
		 * @inheritDoc
		 */
		override public function update(commit:Commit, entity:Entity):void
		{
			var data:Object = serialize([entity])[0];
			invoke(function():void
			{
				if (_fixtures[data.id] == null) {
					commit.failed([entity], new Fault("", "Entity '" + entity.reflect.name + "' with ID=" + data.id + " does not exist"));
				} else {
					_fixtures[data.id] = data;
					commit.saved([entity]);
				}
			});
		}
		
		/**
		 * @inheritDoc
		 */
		override protected function serialize(entities:Array):Array
		{
			return entities.map(function(entity:Entity, ...args):Object
			{
				return entity.toObject();
			});
		}
		
		private function get latency():Number
		{
			return _options.latency;
		}
	}
}