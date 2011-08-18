package mesh.model.store
{
	import collections.HashSet;
	
	import flash.events.EventDispatcher;
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;
	
	import mesh.core.array.intersection;
	import mesh.core.reflection.newInstance;
	import mesh.model.Entity;
	import mesh.model.query.Queries;
	import mesh.model.query.Query;
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
		private var _index:EntityIndex;
		
		private var _changes:HashSet = new HashSet();
		private var _commits:Array = [];
		
		private var _dataSource:Source;
		
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
		 * Commits the entities from this store to its data source. If no entities are given,
		 * then all entities belonging to the store are committed.
		 * 
		 * @param entities The entities to commit, or empty if all entities should be committed.
		 */
		public function commit(...entities):void
		{
			_commits.push( new Commit(this, _dataSource, snapshot(entities.length == 0 ? _changes.toArray() : intersection(entities, _changes.toArray()))) );
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
				var entity:Entity = _index.findByTypeAndID(args[0], args[1]);
				
				// The entity doesn't exist in the store yet. Load it.
				if (entity == null) {
					entity = newInstance(args[0]);
					entity.id = args[1];
				}
				return entity;
			}
			
			// A result list is being requested.
			if (args[0] is Query) {
				return query.results(args[0]);
			}
			
			throw new ArgumentError("Invalid find arguments: " + args);
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
			if (_index.contains(entity)) {
				throw new ArgumentError("Entity '" + entity + "' already belongs to store");
			}
			entity.storeKey = generateStoreKey();
			entity.store = this;
			entity.addEventListener(PropertyChangeEvent.PROPERTY_CHANGE, handleEntityPropertyChange);
			
			if (entity.isDirty) {
				_changes.add(entity);
			}
			
			_index.add(entity);
		}
		
		private function snapshot(entities:Array):Array
		{
			var snapshot:ByteArray = new ByteArray();
			snapshot.writeObject(entities);
			snapshot.position = 0;
			return snapshot.readObject();
		}
		
		private function unregister(entity:Entity):void
		{
			if (!_index.contains(entity)) {
				throw new ArgumentError("Entity '" + entity + "' not found in store");
			}
			entity.store = null;
			entity.removeEventListener(PropertyChangeEvent.PROPERTY_CHANGE, handleEntityPropertyChange);
			_index.remove(entity);
			_changes.remove(entity);
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

import collections.HashSet;

import flash.utils.Dictionary;

import mesh.core.reflection.reflect;
import mesh.model.Entity;

/**
 * An index of the data in a store.
 * 
 * @author Dan Schultz
 */
class EntityIndex extends HashSet
{
	private var _keyToEntity:Dictionary = new Dictionary();
	private var _typeToEntities:Dictionary = new Dictionary();
	
	/**
	 * Constructor.
	 */
	public function EntityIndex()
	{
		
	}
	
	/**
	 * @inheritDoc
	 */
	override public function add(entity:Object):Boolean
	{
		if (super.add(entity)) {
			_keyToEntity[entity.storeKey] = entity;
			findByType(entity).add(entity);
			return true;
		}
		return false;
	}
	
	/**
	 * @inheritDoc
	 */
	override public function contains(entity:Object):Boolean
	{
		return findByKey(entity.storeKey) != null;
	}
	
	/**
	 * Returns an <code>Entity</code> that has the given store key.
	 * 
	 * @param key The store key mapped to an entity.
	 * @return An entity with the given store key.
	 */
	public function findByKey(key:Object):Entity
	{
		return _keyToEntity[key];
	}
	
	/**
	 * Returns a set of entities that are of the given type.
	 * 
	 * @param type The type of entity.
	 * @return All entities in this index with the given type.
	 */
	public function findByType(type:Object):HashSet
	{
		type = reflect(type).clazz;
		if (_typeToEntities[type] == null) {
			_typeToEntities[type] = new HashSet();
		}
		return _typeToEntities[type];
	}
	
	/**
	 * Returns the entity in this index with the given type and identifier.
	 * 
	 * @param type The type of entity.
	 * @param id The ID of the entity.
	 * @return An entity, or <code>null</code> if one was not found.
	 */
	public function findByTypeAndID(type:Class, id:Object):Entity
	{
		for each (var entity:Entity in findByType(type)) {
			if (id === entity.id) {
				return entity;
			}
		}
		return null;
	}
	
	/**
	 * @inheritDoc
	 */
	override public function remove(entity:Object):Boolean
	{
		if (super.remove(entity)) {
			delete _keyToEntity[entity.storeKey];
			findByType(entity).remove(entity);
			return true;
		}
		return false;
	}
}
