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
		
		public function StoreIndex(store:Store)
		{
			_store = store;
		}
		
		public function add(storeKey:Object, entityType:Class, data:Object, id:Object = null):void
		{
			if (contains(storeKey)) {
				throw new IllegalOperationError("Cannot reindex data for store key '" + storeKey + "'");
			}
			
			var obj:SourceData = new SourceData(storeKey, entityType, data);
			_keyToData[storeKey] = obj;
			findByType(entityType).add(obj);
		}
		
		public function contains(storeKey:Object):Boolean
		{
			return _keyToData[storeKey] != null;
		}
		
		public function findByKey(key:Object):SourceData
		{
			return _typeToData[key];
		}
		
		public function findByType(type:Object):List
		{
			type = reflect(type).clazz;
			if (_typeToData[type] == null) {
				_typeToData[type] = new List();
			}
			return _typeToData[type];
		}
		
		public function remove(storeKey:Object):void
		{
			if (!contains(storeKey)) {
				throw new IllegalOperationError("Data not found for store key '" + storeKey + "'");
			}
			
			var data:SourceData = _keyToData[storeKey];
			delete _keyToData[storeKey];
			findByType(data.entityType).remove(data);
		}
	}
}