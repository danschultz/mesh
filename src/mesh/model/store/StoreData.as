package mesh.model.store
{
	import mesh.model.Entity;
	
	public class StoreData
	{
		private var _materializer:Function;
		
		public function StoreData(storeKey:Object, entityType:Class, data:Object, id:Object, materializer:Function)
		{
			_storeKey = storeKey;
			_entityType = entityType;
			_data = data;
			_id = id;
			_materializer = materializer;
		}
		
		public function materialize():Entity
		{
			var entity:Entity = new _entityType();
			_materializer(entity, data);
			return entity;
		}
		
		public function update(store:Store, data:Object):void
		{
			_data = data;
			
			// TODO: Update the values in the mapped Entity.
		}
		
		private var _data:Object;
		public function get data():Object
		{
			return _data;
		}
		
		private var _entityType:Class;
		public function get entityType():Class
		{
			return _entityType;
		}
		
		private var _id:Object;
		public function get id():Object
		{
			return _id;
		}
		
		private var _storeKey:Object;
		public function get storeKey():Object
		{
			return _storeKey;
		}
	}
}