package mesh.model.source
{
	import mesh.model.Record;
	import mesh.model.store.Data;
	import mesh.model.store.Store;
	import mesh.operations.Operation;

	public class RetrieveRequest extends DataSourceRequest
	{
		private var _record:Record;
		
		public function RetrieveRequest(store:Store, record:Record)
		{
			super(store, record.reflect.clazz, record);
			_record = record;
		}
		
		override protected function invoke(store:Store, dataSource:DataSource):Operation
		{
			return dataSource.retrieve(this);
		}
		
		override public function result(data:Object):void
		{
			Data( data ).transferValues(_record);
		}
		
		public function get id():*
		{
			return _record.id;
		}
	}
}