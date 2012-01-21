package mesh.model.store
{
	import mesh.model.Record;
	import mesh.model.source.DataSource;
	import mesh.operations.Operation;

	public class RetrieveRequest extends DataSourceRequest
	{
		private var _record:Record;
		
		public function RetrieveRequest(store:Store, record:Record)
		{
			super(store, record);
			_record = record;
		}
		
		override protected function invoke(store:Store, dataSource:DataSource):Operation
		{
			return dataSource.retrieve(store, _record.id, _record.reflect.clazz);
		}
		
		public function result(data:Data):void
		{
			data.transferValues(_record);
		}
		
		public function get id():*
		{
			return _record.id;
		}
		
		public function get recordType():Class
		{
			return _record.reflect.clazz;
		}
	}
}