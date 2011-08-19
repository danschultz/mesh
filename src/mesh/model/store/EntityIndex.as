package mesh.model.store
{
	import collections.HashSet;
	
	import flash.utils.Dictionary;
	
	import mesh.core.List;
	import mesh.core.reflection.reflect;
	import mesh.model.Entity;
	
	/**
	 * An index of the data in a store.
	 * 
	 * @author Dan Schultz
	 */
	public class EntityIndex extends HashSet
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
		public function findByType(type:Object):List
		{
			type = reflect(type).clazz;
			if (_typeToEntities[type] == null) {
				_typeToEntities[type] = new List();
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
}