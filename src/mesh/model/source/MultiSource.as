package mesh.model.source
{
	import flash.errors.IllegalOperationError;
	import flash.utils.Dictionary;
	
	import mesh.core.reflection.reflect;
	import mesh.model.Entity;
	import mesh.model.store.Store;

	/**
	 * An entity source that maps a type of entity to its source.
	 * 
	 * <p>
	 * This source respects the inhertence of entities. For instance, say you have 
	 * entity <code>A</code>, and entity <code>B</code> that extends from <code>A</code>. 
	 * If you map <code>A</code> to an source, then <code>B</code> will use the same 
	 * source as <code>A</code>.
	 * </p>
	 * 
	 * @author Dan Schultz
	 */
	public class MultiSource extends Source
	{
		private var _mapping:Dictionary = new Dictionary();
		
		/**
		 * Constructor.
		 */
		public function MultiSource()
		{
			super();
		}
		
		/**
		 * Maps an entity type to an entity source. This source respects the inhertence 
		 * of entities. For instance, say you have entity <code>A</code>, and entity 
		 * <code>B</code> that extends from <code>A</code>. If you map <code>A</code> to
		 * an source, then <code>B</code> will use the same source as <code>A</code>.
		 * 
		 * @param entity The entity type to map.
		 * @param source The source to use for the entity.
		 */
		public function map(entity:Class, source:Source):void
		{
			_mapping[entity] = source;
		}
		
		/**
		 * @inheritDoc
		 */
		override public function create(store:Store, entity:Entity):void
		{
			invoke(store, "create", entity);
		}
		
		/**
		 * @inheritDoc
		 */
		override public function createEach(store:Store, entities:Array):void
		{
			invokeEach(store, "createEach", entities);
		}
		
		/**
		 * @inheritDoc
		 */
		override public function destroy(store:Store, entity:Entity):void
		{
			invoke(store, "destroy", entity);
		}
		
		/**
		 * @inheritDoc
		 */
		override public function destroyEach(store:Store, entities:Array):void
		{
			invokeEach(store, "destroyEach", entities);
		}
		
		/**
		 * @inheritDoc
		 */
		override public function retrieve(store:Store, entity:Entity):void
		{
			invoke(store, "retrieve", entity);
		}
		
		/**
		 * @inheritDoc
		 */
		override public function retrieveEach(store:Store, entities:Array):void
		{
			invokeEach(store, "retrieveEach", entities);
		}
		
		/**
		 * @inheritDoc
		 */
		override public function update(store:Store, entity:Entity):void
		{
			invoke(store, "update", entity);
		}
		
		/**
		 * @inheritDoc
		 */
		override public function updateEach(store:Store, entities:Array):void
		{
			invokeEach(store, "updateEach", entities);
		}
		
		/**
		 * Returns the entity source that is mapped to the given entity. If no source is
		 * mapped, then <code>null</code> is returned.
		 * 
		 * @param entity The entity type to get the source for.
		 * @return The source mapped to the given entity.
		 */
		protected function sourceFor(entity:Class):Source
		{
			return _mapping[entity];
		}
		
		private function invoke(store:Store, method:String, entity:Entity):void
		{
			var type:Class = entity.reflect.clazz;
			throwIfUnmapped(type);
			sourceFor(type)[method](store, entity);
		}
		
		private function invokeEach(store:Store, method:String, entities:Array):void
		{
			var grouped:Dictionary = groupByType(entities);
			for (var type:* in grouped) {
				throwIfUnmapped(type);
				sourceFor(type)[method](store, grouped[type]);
			}
		}
		
		private function groupByType(entities:Array):Dictionary
		{
			var result:Dictionary = new Dictionary();
			for each (var entity:Entity in entities) {
				var type:Class = entity.reflect.clazz;
				if (result[type] == null) {
					result[type] = [];
				}
				(result[type] as Array).push(entity);
			}
			return result;
		}
		
		private function throwIfUnmapped(entity:Class):void
		{
			if (sourceFor(entity) == null) {
				throw new IllegalOperationError("Source undefined for " + reflect(entity).name);
			}
		}
	}
}