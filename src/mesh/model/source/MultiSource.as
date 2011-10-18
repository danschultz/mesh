package mesh.model.source
{
	import flash.errors.IllegalOperationError;
	import flash.utils.Dictionary;
	
	import mesh.core.reflection.reflect;
	import mesh.model.Entity;
	import mesh.model.store.Commit;
	import mesh.model.store.Query;
	import mesh.model.store.ResultList;
	import mesh.model.store.Snapshot;

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
		override public function create(commit:Commit, snapshot:Snapshot):void
		{
			invoke(commit, "create", snapshot);
		}
		
		/**
		 * @inheritDoc
		 */
		override public function createEach(commit:Commit, snapshots:Array):void
		{
			invokeEach(commit, "createEach", snapshots);
		}
		
		/**
		 * @inheritDoc
		 */
		override public function destroy(commit:Commit, snapshot:Snapshot):void
		{
			invoke(commit, "destroy", snapshot);
		}
		
		/**
		 * @inheritDoc
		 */
		override public function destroyEach(commit:Commit, snapshots:Array):void
		{
			invokeEach(commit, "destroyEach", snapshots);
		}
		
		/**
		 * @inheritDoc
		 */
		override public function fetch(query:Query, results:ResultList):void
		{
			sourceFor(query.entityType).fetch(query, results);
		}
		
		/**
		 * @inheritDoc
		 */
		override public function retrieve(entity:Entity):void
		{
			invoke(null, "retrieve", entity);
		}
		
		/**
		 * @inheritDoc
		 */
		override public function retrieveEach(entities:Array):void
		{
			invokeEach(null, "retrieveEach", entities);
		}
		
		/**
		 * @inheritDoc
		 */
		override public function update(commit:Commit, snapshot:Snapshot):void
		{
			invoke(commit, "update", snapshot);
		}
		
		/**
		 * @inheritDoc
		 */
		override public function updateEach(commit:Commit, snapshots:Array):void
		{
			invokeEach(commit, "updateEach", snapshots);
		}
		
		/**
		 * Returns the entity source that is mapped to the given entity. If no source is
		 * mapped, then <code>null</code> is returned.
		 * 
		 * @param entity The entity type to get the source for.
		 * @return The source mapped to the given entity.
		 */
		protected function sourceFor(entity:Object):Source
		{
			entity = entity is Entity ? (entity as Entity).reflect.clazz : entity;
			
			var source:Source = _mapping[entity];
			if (source != null) {
				return source;
			}
			
			var parent:Class = reflect(entity).parent.clazz;
			if (parent != Entity) {
				return sourceFor(parent);
			}
			
			return null;
		}
		
		private function invoke(commit:Object, method:String, snapshotOrEntity:Object):void
		{
			var entity:Entity = snapshotOrEntity is Snapshot ? (snapshotOrEntity as Snapshot).entity : Entity( snapshotOrEntity );
			var source:Source = sourceFor(entity);
			throwIfSourceIsNull(source, entity);
			source[method].apply(null, commit == null ? [snapshotOrEntity] : [commit, snapshotOrEntity]);
		}
		
		private function invokeEach(commit:Object, method:String, snapshotsOrEntities:Array):void
		{
			var grouped:Dictionary = groupBySource(snapshotsOrEntities);
			for (var source:* in grouped) {
				source[method].apply(null, commit == null ? [snapshotsOrEntities] : [commit, snapshotsOrEntities]);
			}
		}
		
		private function groupBySource(snapshotsOrEntities:Array):Dictionary
		{
			var result:Dictionary = new Dictionary();
			for each (var snapshotOrEntity:Object in snapshotsOrEntities) {
				var entity:Entity = snapshotOrEntity is Snapshot ? (snapshotOrEntity as Snapshot).entity : Entity( snapshotOrEntity );
				var source:Source = sourceFor(entity);
				throwIfSourceIsNull(source, entity);
				
				if (result[source] == null) {
					result[source] = [];
				}
				(result[source] as Array).push(snapshotOrEntity);
			}
			return result;
		}
		
		private function throwIfSourceIsNull(source:Source, entity:Entity):void
		{
			if (source == null) {
				throwUnmappedError(entity);
			}
		}
		
		private function throwUnmappedError(entity:Entity):void
		{
			throw new IllegalOperationError("Source undefined for '" + entity.reflect.name + "'");
		}
	}
}