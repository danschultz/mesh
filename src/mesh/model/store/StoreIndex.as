package mesh.model.store
{
	import flash.errors.IllegalOperationError;
	import flash.utils.Dictionary;
	
	import mesh.core.List;
	import mesh.core.reflection.reflect;

	public class StoreIndex
	{
		private var _store:Store;
		
		private var _keyToData:Dictionary = new Dictionary();
		private var _typeToData:Dictionary = new Dictionary();
		private var _typeToKeys:Dictionary = new Dictionary();
		private var _typeToIDs:Dictionary = new Dictionary();
		
		public function StoreIndex(store:Store)
		{
			_store = store;
		}
		
		public function add(storeKey:Object, entityType:Class, data:Object, id:Object, materializer:Function):void
		{
			if (contains(storeKey)) {
				throw new IllegalOperationError("Cannot reindex data for store key '" + storeKey + "'");
			}
			
			var obj:StoreData = new StoreData(storeKey, entityType, data, id, materializer);
			_keyToData[storeKey] = obj;
			findByType(entityType).add(obj);
			keysForType(entityType).add(storeKey);
			indexDataID(obj);
		}
		
		public function contains(storeKey:Object):Boolean
		{
			return _keyToData[storeKey] != null;
		}
		
		public function findByKey(key:Object):StoreData
		{
			return _keyToData[key];
		}
		
		public function findByType(type:Object):List
		{
			type = reflect(type).clazz;
			if (_typeToData[type] == null) {
				_typeToData[type] = new List();
			}
			return _typeToData[type];
		}
		
		public function findByTypeAndID(type:Object, id:Object):StoreData
		{
			var index:Dictionary = typeIndex(type);
			return index != null ? index[id] : null;
		}
		
		private function indexDataID(data:StoreData):void
		{
			if (data.id != null && data.id != 0) {
				var index:Dictionary = typeIndex(data.entityType);
				
				// Check if an ID already exists.
				if (index[data.id] != null) {
					throw new IllegalOperationError("Duplicate data for '" + reflect(data.entityType).name + "' with ID=" + data.id + ".");
				}
				
				index[data.id] = data;
			}
		}
		
		public function keysForType(type:Object):List
		{
			type = reflect(type).clazz;
			if (_typeToKeys[type] == null) {
				_typeToKeys[type] = new List();
			}
			return _typeToKeys[type];
		}
		
		public function remove(storeKey:Object):void
		{
			if (!contains(storeKey)) {
				throw new IllegalOperationError("Data not found for store key '" + storeKey + "'");
			}
			
			var data:StoreData = _keyToData[storeKey];
			delete _keyToData[storeKey];
			findByType(data.entityType).remove(data);
			keysForType(data.entityType).remove(storeKey);
			unindexDataID(data.entityType, data.id);
		}
		
		private function typeIndex(type:Object):Dictionary
		{
			type = type is Class ? type : reflect(type).clazz;
			if (_typeToIDs[type] == null) {
				_typeToIDs[type] = new Dictionary();
			}
			return _typeToIDs[type];
		}
		
		private function unindexDataID(type:Object, id:Object):void
		{
			delete typeIndex(type)[id];
		}
	}
}