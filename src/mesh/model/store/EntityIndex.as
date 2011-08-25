package mesh.model.store
{
	import collections.HashSet;
	
	import flash.errors.IllegalOperationError;
	import flash.utils.Dictionary;
	
	import mesh.core.List;
	import mesh.core.reflection.reflect;
	import mesh.model.Entity;
	
	import mx.events.PropertyChangeEvent;
	
	/**
	 * An index of the data in a store.
	 * 
	 * @author Dan Schultz
	 */
	public class EntityIndex extends HashSet
	{
		private var _keyToEntity:Dictionary = new Dictionary();
		private var _typeToEntities:Dictionary = new Dictionary();
		private var _typeToIDs:Dictionary = new Dictionary();
		
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
				indexEntityID(entity as Entity);
				entity.addEventListener(PropertyChangeEvent.PROPERTY_CHANGE, handleEntityPropertyChange);
				return true;
			}
			return false;
		}
		
		/**
		 * @inheritDoc
		 */
		override public function contains(entity:Object):Boolean
		{
			return findByKey(entity.storeKey) != null || findByTypeAndID(entity.reflect.clazz, entity.id) != null;
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
			var index:Dictionary = typeIndex(type);
			return index != null ? index[id] : null;
		}
		
		private function handleEntityPropertyChange(event:PropertyChangeEvent):void
		{
			if (event.property == "id") {
				indexEntityID(Entity( event.target ));
			}
		}
		
		private function indexEntityID(entity:Entity):void
		{
			if (entity.id != null && entity.id != 0) {
				var index:Dictionary = typeIndex(entity);
				
				// Check if an ID already exists.
				if (index[entity.id] != null) {
					throw new IllegalOperationError("Duplicate '" + entity.reflect.name + "' with ID=" + entity.id + ".");
				}
				
				index[entity.id] = entity;
			}
		}
		
		/**
		 * @inheritDoc
		 */
		override public function remove(entity:Object):Boolean
		{
			if (super.remove(entity)) {
				delete _keyToEntity[entity.storeKey];
				findByType(entity).remove(entity);
				unindexEntityID(entity, entity.id);
				entity.removeEventListener(PropertyChangeEvent.PROPERTY_CHANGE, handleEntityPropertyChange);
				return true;
			}
			return false;
		}
		
		private function typeIndex(type:Object):Dictionary
		{
			type = type is Class ? type : reflect(type).clazz;
			if (_typeToIDs[type] == null) {
				_typeToIDs[type] = new Dictionary();
			}
			return _typeToIDs[type];
		}
		
		private function unindexEntityID(type:Object, id:Object):void
		{
			delete typeIndex(type)[id];
		}
	}
}