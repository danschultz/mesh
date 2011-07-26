package mesh.model
{
	import collections.HashSet;
	
	import flash.events.EventDispatcher;
	import flash.utils.Dictionary;
	
	import mesh.core.reflection.newInstance;
	import mesh.source.EntitySource;
	
	import mx.events.PropertyChangeEvent;

	public class EntityStore extends EventDispatcher
	{
		private var _keyCounter:Number = 0;
		private var _keyToEntity:Dictionary = new Dictionary();
		private var _dataSource:EntitySource;
		private var _changes:HashSet = new HashSet();
		
		public function EntityStore(dataSource:EntitySource)
		{
			super();
			_dataSource = dataSource;
		}
		
		public function commit(entities:Object):void
		{
			
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
				entity.storeKey = ++_keyCounter;
				store(entity);
			}
			
			return entity;
		}
		
		public function destroy(...args):void
		{
			
		}
		
		public function find(...args):void
		{
			
		}
		
		private function handleEntityPropertyChange(event:PropertyChangeEvent):void
		{
			var entity:Entity = Entity( event.source );
			if (event.property == "state") {
				if (entity.isInState(Entity.DIRTY)) {
					_changes.add(entity);
				} else if (entity.isInState(Entity.CLEAN)) {
					_changes.remove(entity);
				}
			}
		}
		
		private function purge(entity:Entity):void
		{
			if (_keyToEntity[entity.storeKey] == null) {
				throw new ArgumentError("Entity '" + entity + "' not found in store");
			}
			entity.removeEventListener(PropertyChangeEvent.PROPERTY_CHANGE, handleEntityPropertyChange);
			delete _keyToEntity[entity.storeKey];
		}
		
		private function store(entity:Entity):void
		{
			_keyToEntity[entity.storeKey] = entity;
			entity.addEventListener(PropertyChangeEvent.PROPERTY_CHANGE, handleEntityPropertyChange);
		}
	}
}