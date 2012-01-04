package mesh.model.store
{
	import mesh.model.Entity;

	public class EntityRequest extends StoreRequest
	{
		private var _entity:Entity;
		
		public function EntityRequest(entity:Entity, store:Store)
		{
			super(store);
			_entity = entity;
		}
		
		override public function result(data:Data):void
		{
			store.entities.add(entity);
			store.data.add(data);
			data.transferValues(entity);
			super.result(data);
		}
		
		public function get entity():Entity
		{
			return _entity;
		}
	}
}