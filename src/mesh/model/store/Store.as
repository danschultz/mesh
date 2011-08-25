package mesh.model.store
{
	import collections.HashSet;
	
	import flash.events.EventDispatcher;
	
	import mesh.core.reflection.newInstance;
	import mesh.model.Entity;
	import mesh.model.source.Source;
	
	import mx.events.PropertyChangeEvent;
	
	/**
	 * The store represents a repository for all <code>Entity</code>s in your application. The store
	 * is assigned a data source, which is responsible for persisting the changes to each entity.
	 * 
	 * @author Dan Schultz
	 */
	public class Store extends EventDispatcher
	{
		private var _keyCounter:Number = 0;
		private var _changes:HashSet = new HashSet();
		
		/**
		 * Constructor.
		 * 
		 * @param dataSource The store's data source.
		 */
		public function Store(dataSource:Source)
		{
			super();
			
			_index = new EntityIndex();
			_queries = new Queries(this);
			_commits = new Commits(this, _changes);
			_dataSource = dataSource;
		}
		
		/**
		 * Adds entities to the store. Once added, the entities will be indexed, tracked for
		 * changes, and given a store key.
		 * 
		 * @param entities The entities to add.
		 */
		public function add(...entities):void
		{
			for each (var entity:Entity in entities) {
				register(entity);
			}
		}
		
		/**
		 * Commits the entities from this store to their data source. If no entities are given,
		 * then all entities belonging to the store are committed.
		 * 
		 * @param entities The entities to commit, or empty if all entities should be committed.
		 */
		public function commit(...entities):void
		{
			_commits.commit(entities);
		}
		
		/**
		 * Finds a single entity for a specific ID, or returns a list of entities 
		 * matching a query.
		 * 
		 * <p>
		 * If you supply an entity type and an ID, then this method returns a single
		 * <code>Entity</code>. If the entity has not been loaded into the store, then 
		 * the store will ask the data source to load it. All properties on the entity
		 * will be empty until the data source has loaded the data.
		 * </p>
		 * 
		 * <p>
		 * If you supply a query, then this method returns a <code>ResultList</code>
		 * of all entities that match the conditions of the query.
		 * </p>
		 * 
		 * @param args A entity type and an ID, or a <code>Query</code>.
		 * @return An <code>Entity</code> or <code>ResultList</code>.
		 */
		public function find(...args):*
		{
			// A single entity is being requested.
			if (args.length == 2 && args[0] is Class) {
				var entity:Entity = index.findByTypeAndID(args[0], args[1]);
				
				// The entity doesn't exist in the store yet. Load it.
				if (entity == null) {
					entity = newInstance(args[0]);
					entity.id = args[1];
					dataSource.retrieve(this, entity);
				}
				return entity;
			}
			
			// A result list is being requested.
			if (args[0] is Query) {
				return query.results(args[0]);
			}
			
			throw new ArgumentError("Invalid arguments for find(): " + args);
		}
		
		/**
		 * Returns a new globally unique store ID.
		 * 
		 * @return A new store ID.
		 */
		protected function generateStoreKey():Number
		{
			return ++_keyCounter;
		}
		
		private function handleEntityPropertyChange(event:PropertyChangeEvent):void
		{
			var entity:Entity = Entity( event.source );
			if (event.property == "state") {
				if (entity.isDirty) {
					_changes.add(entity);
				} else if (entity.isSynced) {
					_changes.remove(entity);
				}
			}
		}
		
		private function register(entity:Entity):void
		{
			entity.storeKey = generateStoreKey();
			entity.store = this;
			entity.addEventListener(PropertyChangeEvent.PROPERTY_CHANGE, handleEntityPropertyChange);
			
			if (entity.isNew) {
				_changes.add(entity);
			}
			
			index.add(entity);
		}
		
		private function unregister(entity:Entity):void
		{
			if (!index.contains(entity)) {
				throw new ArgumentError("Entity '" + entity + "' not found in store");
			}
			entity.store = null;
			entity.removeEventListener(PropertyChangeEvent.PROPERTY_CHANGE, handleEntityPropertyChange);
			index.remove(entity);
			_changes.remove(entity);
		}
		
		private var _commits:Commits;
		/**
		 * The history of commits that the store has made.
		 */
		public function get commits():Commits
		{
			return _commits;
		}
		
		private var _dataSource:Source;
		/**
		 * The data source assigned to this store, which is responsible for persisting changed entities
		 * to a backend.
		 */
		internal function get dataSource():Source
		{
			return _dataSource;
		}
		
		private var _index:EntityIndex;
		/**
		 * The internal index of <code>Entity</code>s used by the store.
		 */
		internal function get index():EntityIndex
		{
			return _index;
		}
		
		private var _queries:Queries;
		/**
		 * The queries and their cached results that have been invoked on this store.
		 */
		public function get query():Queries
		{
			return _queries;
		}
	}
}
