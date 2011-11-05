package mesh.model.store
{
	import collections.HashSet;
	
	import flash.events.EventDispatcher;
	
	import mesh.core.object.merge;
	import mesh.core.state.StateEvent;
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
		private static const DEFAULT_MATERIALIZER:Function = function(entity:Entity, data:Object):void
		{
			entity.fromObject(data);
		}
		
		private var _keyCounter:Number = 0;
		private var _changes:HashSet = new HashSet();
		private var _requests:Requests;
		
		/**
		 * Constructor.
		 * 
		 * @param dataSource The store's data source.
		 */
		public function Store(dataSource:Source)
		{
			super();
			
			_data = new StoreIndex(this);
			_entities = new EntityIndex();
			_queries = new Queries(this);
			_commits = new Commits(this, _changes);
			_requests = new Requests(this);
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
				register(entity, generateStoreKey());
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
		 * Creates a new entity of the given type and given data.
		 * 
		 * @param entityType The type of entity to create.
		 * @param data The data for the entity.
		 * @return A new entity.
		 */
		public function create(entityType:Class, data:Object):*
		{
			var key:Object = generateStoreKey();
			_data.add(key, entityType, data, null, DEFAULT_MATERIALIZER);
			return materialize(key);
		}
		
		/**
		 * Finds a single entity for a specific ID, or a list of entities matching a query.
		 * 
		 * <p>
		 * If you supply an entity type and an ID, then this method returns a single <code>Entity</code>. 
		 * If the entity has not been loaded into the store, then the store will ask the data source 
		 * to load it. All properties on the entity will be empty until the data source has loaded 
		 * the data.
		 * </p>
		 * 
		 * <p>
		 * The last argument is an optional options hash to configure the find. The following options
		 * are supported:
		 * 
		 * <ul>
		 * <li><code>useBusyCursor:Boolean</code> - (default=<code>true</code>) Will display a busy 
		 * 	cursor while data is loading.</li>
		 * <li><code>reload:Boolean</code> - (default=<code>false</code>) Will reload the data if its 
		 * 	already been loaded.</li>
		 * </ul>
		 * </p>
		 * 
		 * <p>
		 * If you supply a query, then this method returns a <code>ResultList</code>
		 * of all entities that match the conditions of the query.
		 * </p>
		 * 
		 * @param args A entity type and an ID, or a <code>Query</code>.
		 * @return An request object.
		 */
		public function find(...args):*
		{
			// Retrieve an Entity
			if (args.length == 2) {
				return retrieveEntity(args[0], args[1]);
			}
			// Find a query.
			else if (args[0] is Query) {
				return findQuery(args[0]);
			}
			
			// Can't parse the arguments.
			throw new ArgumentError("Invalid arguments for find(): " + args);
		}
		
		private function findQuery(q:Query):ResultList
		{
			var results:ResultList = queries.results(q);
			dataSource.fetch(q, this, results);
			return results;
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
		
		private function handleEntityStatusStateChange(event:StateEvent):void
		{
			var oldHasChanges:Boolean = hasChanges;
			
			var entity:Entity = Entity( event.target );
			if (entity.status.isDirty) {
				_changes.add(entity);
			} else if (entity.status.isSynced) {
				_changes.remove(entity);
			}
			
			dispatchEvent(PropertyChangeEvent.createUpdateEvent(this, "hasChanges", oldHasChanges, hasChanges));
		}
		
		/**
		 * Adds data that was retrieved from a data source into the store.
		 * 
		 * <p>
		 * This method accepts an options hash to configure the insert:
		 * 
		 * <ul>
		 * <li>id:<code>Object</code> – The ID to assign to the data. If undefined, the ID is 
		 * 	parsed from the data's <code>id</code> property.</li>
		 * <li>materializer:<code>Function</code> – The function that copies the values from
		 * 	the <code>data</code> object, to an <code>Entity</code> when it's initialized. The
		 * 	function must have the following signature: 
		 * 	<code>function(entity:Entity, data:Object):void</code>.
		 * </ul>
		 * </p>
		 * 
		 * @param entityType The type of entity to map the data to.
		 * @param data The data to insert.
		 * @param options An options hash to configure the insert.
		 * @return The store key of the inserted data.
		 */
		public function insert(entityType:Class, data:Object, options:Object = null):Object
		{
			options = merge({id:data.id, materializer:DEFAULT_MATERIALIZER}, options);
			
			var source:SourceData = this.data.findByTypeAndID(entityType, options.id);
			if (source == null) {
				var key:Object = generateStoreKey();
				_data.add(key, entityType, data, options.id, options.materializer);
				return key;
			}
			
			source.update(this, data);
			return source.storeKey;
		}
		
		/**
		 * Materializes the data hash that's mapped to the given key into an <code>Entity</code>.
		 * 
		 * @param key The key to materialize.
		 * @return An entity.
		 */
		public function materialize(key:Object):Entity
		{
			var entity:Entity = entities.findByKey(key);
			
			if (entity == null) {
				var source:SourceData = data.findByKey(key);
				if (source == null) throw new ArgumentError("Data undefined for key '" + key + "'");
				entity = source.materialize();
				register(entity, source.storeKey);
			}
			
			return entity;
		}
		
		private function register(entity:Entity, storeKey:Object):void
		{
			entity.storeKey = storeKey;
			entity.store = this;
			entity.addEventListener(StateEvent.ENTER, handleEntityStatusStateChange);
			
			if (entity.status.isNew) {
				_changes.add(entity);
			}
			
			entities.add(entity);
		}
		
		/**
		 * Removes entities from the store.
		 * 
		 * @param entities The entities to remove.
		 */
		public function remove(...entities):void
		{
			for each (var entity:Entity in entities) {
				unregister(entity);
			}
		}
		
		private function retrieveEntity(type:Class, id:Object):Entity
		{
			var entity:Entity = entities.findByTypeAndID(type, id);
			if (entity == null) {
				entity = new type();
				entity.id = id;
			}
			dataSource.retrieve(entity);
			return entity;
		}
		
		private function unregister(entity:Entity):void
		{
			if (!entities.contains(entity)) {
				throw new ArgumentError("Entity '" + entity + "' not found in store");
			}
			entity.store = null;
			entity.removeEventListener(StateEvent.ENTER, handleEntityStatusStateChange);
			entities.remove(entity);
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
		
		private var _data:StoreIndex;
		/**
		 * The internal index used by the store.
		 */
		internal function get data():StoreIndex
		{
			return _data;
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
		
		private var _entities:EntityIndex;
		/**
		 * The internal index of <code>Entity</code>s used by the store.
		 */
		internal function get entities():EntityIndex
		{
			return _entities;
		}
		
		[Bindable(event="propertyChange")]
		/**
		 * <code>true</code> if the store has uncommitted changes.
		 */
		public function get hasChanges():Boolean
		{
			return _changes.length > 0;
		}
		
		private var _queries:Queries;
		/**
		 * The queries and their cached results that have been invoked on this store.
		 */
		public function get queries():Queries
		{
			return _queries;
		}
	}
}
