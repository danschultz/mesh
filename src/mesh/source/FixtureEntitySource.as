package mesh.source
{
	import flash.errors.IllegalOperationError;
	import flash.utils.Dictionary;
	
	import mesh.core.object.merge;
	import mesh.model.Entity;
	import mesh.model.EntityStore;

	public class FixtureEntitySource extends EntitySource
	{
		private var _fixtures:Dictionary = new Dictionary();
		private var _idCounter:int;
		private var _options:Object;
		
		/**
		 * Constructor.
		 * 
		 * @param options The options for this source.
		 */
		public function FixtureEntitySource(options:Object = null)
		{
			super();
			_options = merge({latency:250}, options);
		}
		
		/**
		 * @inheritDoc
		 */
		override public function create(store:EntityStore, entity:Entity):void
		{
			if (!entity.isNew) {
				throw new ArgumentError("Attempted to create an non-new entity.");
			}
			entity.id = ++_idCounter;
			update(store, entity);
		}
		
		/**
		 * @inheritDoc
		 */
		override public function destroy(store:EntityStore, entity:Entity):void
		{
			if (_fixtures[entity.id] == null) {
				throw new IllegalOperationError("Attempted to destroy a non-existent entity.");
			}
			delete _fixtures[entity.id];
		}
		
		/**
		 * @inheritDoc
		 */
		override public function update(store:EntityStore, entity:Entity):void
		{
			if (entity.isNew) {
				throw new IllegalOperationError("Attempted to update a new entity.");
			}
			_fixtures[entity.id] = entity.translateTo();
		}
		
		private function get latency():Number
		{
			return _options.latency;
		}
	}
}