package mesh.model.source
{
	import flash.utils.Dictionary;
	import flash.utils.setTimeout;
	
	import mesh.core.object.merge;
	import mesh.core.reflection.newInstance;
	import mesh.model.Entity;
	import mesh.model.store.AsyncRequest;
	import mesh.model.store.Commit;
	import mesh.model.store.Query;
	import mesh.model.store.RemoteQuery;
	import mesh.model.store.Snapshot;
	
	import mx.collections.ArrayList;

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
			_options = merge({latency:0}, options);
		}
		
		private function invoke(block:Function):void
		{
			if (latency > 0) setTimeout(block, latency);
			else block();
		}
		
		/**
		 * @inheritDoc
		 */
		override public function create(commit:Commit, snapshot:Snapshot):void
		{
			var data:Object = serialize([snapshot])[0];
			invoke(function():void
			{
				if (!snapshot.status.isNew) {
					update(commit, snapshot);
				} else {
					data.id = ++_idCounter;
					_fixtures[data.id] = data;
					commit.committed([snapshot], [data.id]);
				}
			});
		}
		
		/**
		 * @inheritDoc
		 */
		override public function fetch(request:AsyncRequest, query:Query):void
		{
			if (query.entityType == _entityType) {
				var entities:Array = [];
				for each (var hash:Object in _fixtures) {
					var entity:Entity = newInstance(_entityType);
					entity.fromObject(hash);
					entities.push(entity);
				}
				
				if (query is RemoteQuery) {
					entities = entities.filter(function(entity:Entity, ...args):Boolean
					{
						return query.contains(entity);
					});
				}
				
				request.result(new ArrayList(entities));
			}
		}
		
		/**
		 * @inheritDoc
		 */
		override public function destroy(commit:Commit, snapshot:Snapshot):void
		{
			var data:Object = serialize([snapshot])[0];
			invoke(function():void
			{
				if (_fixtures[data.id] != null) {
					delete _fixtures[data.id];
					commit.committed([snapshot]);
				} else {
					commit.failed([snapshot], new SourceFault("Failed to destroy entity", "Entity '" + snapshot.entity.reflect.name + "' with ID=" + data.id + " does not exist"));
				}
			});
		}
		
		/**
		 * @inheritDoc
		 */
		override public function retrieve(request:AsyncRequest, entity:Entity):void
		{
			var data:Object = entity.serialize();
			invoke(function():void
			{
				if (_fixtures[data.id] != null) {
					entity.fromObject(_fixtures[data.id]);
					request.result(entity);
				} else {
					request.failed(new SourceFault(entity.reflect.name + " not found with ID=" + entity.id));
				}
			});
		}
		
		/**
		 * @inheritDoc
		 */
		override public function update(commit:Commit, snapshot:Snapshot):void
		{
			var data:Object = serialize([snapshot])[0];
			invoke(function():void
			{
				if (_fixtures[data.id] == null) {
					commit.failed([snapshot], new SourceFault("Failed to update entity", "Entity '" + snapshot.entity.reflect.name + "' with ID=" + data.id + " does not exist"));
				} else {
					_fixtures[data.id] = data;
					commit.committed([snapshot]);
				}
			});
		}
		
		/**
		 * @inheritDoc
		 */
		override protected function serialize(snapshots:Array):Array
		{
			return snapshots.map(function(snapshot:Snapshot, ...args):Object
			{
				return snapshot.materialize().toObject();
			});
		}
		
		private function get latency():Number
		{
			return _options.latency;
		}
	}
}