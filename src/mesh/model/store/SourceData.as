package mesh.model.store
{
	import mesh.model.Entity;
	
	public class SourceData
	{
		public function SourceData(storeKey:Object, entityType:Class, data:Object, id:Object)
		{
			_storeKey = storeKey;
			_entityType = entityType;
			_data = data;
			_id = id;
		}
		
		public function materialize():Entity
		{
			var entity:Entity = new _entityType();
			entity.fromObject(data);
			return entity;
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