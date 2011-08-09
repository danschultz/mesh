package mesh.model
{
	import collections.HashSet;
	
	import flash.events.EventDispatcher;
	import flash.utils.Dictionary;
	
	import mesh.core.array.flatten;
	import mesh.core.reflection.newInstance;
	import mesh.model.query.Queries;
	import mesh.model.query.Query;
	import mesh.source.Source;
	
	import mx.events.PropertyChangeEvent;

	public class Store extends EventDispatcher
	{
		private var _keyCounter:Number = 0;
		private var _index:EntityIndex;
		private var _changes:HashSet = new HashSet();
		
		private var _queries:Queries;
		
		private var _dataSource:Source;
		
		public function Store(dataSource:Source)
		{
			super();
			
			_index = new EntityIndex(this);
			_queries = new Queries(this);
			_dataSource = dataSource;
		}
		
		public function commit(...entities):void
		{
			_dataSource.commit(this, flatten(entities));
		}
		
		public function create(...args):*
		{
			var entity:Entity;
			
			// Create an entity from the defined class, or just use the entity they passed.
			if (args[0] is Class) {
				entity = newInstance.apply(null, args);
			}
			if (args[0] is Entity) {
				entity = args[0];
			}
			
			// Make sure the entity was created, and that it's new.
			if (entity == null) {
				throw new ArgumentError("Cannot create Entity with args '" + args + "'");
			}
			
			if (entity.isNew) {
				register(entity);
			}
			
			return entity;
		}
		
		public function destroy(...entities):void
		{
			for each (var entity:Entity in entities) {
				entity.destroyed().dirty();
			}
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
				
			}
			
			// A result list is being requested.
			if (args[0] is Query) {
				return _queries.result(args[0]);
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
			entity.storeKey = generateStoreKey();
			entity.store = this;
			entity.addEventListener(PropertyChangeEvent.PROPERTY_CHANGE, handleEntityPropertyChange);
			_index.add(entity);
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
	}
}

import collections.HashSet;

import flash.utils.Dictionary;

import mesh.model.Entity;

/**
 * An index for the entities in a store.
 * 
 * @author Dan Schultz
 */
class EntityIndex extends HashSet
{
	private var _keyToEntity:Dictionary = new Dictionary();
	
	/**
	 * Constructor.
	 */
	public function EntityIndex()
	{
		
	}
	
	/**
	 * @inheritDoc
	 */
	override public function add(entity:Entity):Boolean
	{
		if (super.add(entity)) {
			_keyToEntity[entity.storeKey] = entity;
			return true;
		}
		return false;
	}
	
	/**
	 * @inheritDoc
	 */
	override public function contains(entity:Entity):Boolean
	{
		return forKey(entity.storeKey) != null;
	}
	
	/**
	 * Returns an <code>Entity</code> that has the given store key.
	 * 
	 * @param key The store key mapped to an entity.
	 * @return An entity with the given store key.
	 */
	public function forKey(key:Object):Entity
	{
		return _keyToEntity[key];
	}
	
	/**
	 * @inheritDoc
	 */
	override public function remove(entity:Entity):Boolean
	{
		if (super.remove(entity)) {
			delete _keyToEntity[entity.storeKey];
			return true;
		}
		return false;
	}
}
