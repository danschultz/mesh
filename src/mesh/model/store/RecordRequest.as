package mesh.model.store
{
	import mesh.model.Record;

	public class RecordRequest extends StoreRequest
	{
		private var _record:Record;
		
		public function RecordRequest(record:Record, store:Store)
		{
			super(store);
			_record = record;
		}
		
		override public function execute():void
		{
			var data:Data = store.data.findByTypeAndID(record.reflect.clazz, record.id);
			if (data != null) {
				result(data);
			} else {
				store.dataSource.retrieve(this);
			}
		}
		
		override public function result(data:Data):void
		{
			store.records.add(record);
			store.data.add(data);
			data.transferValues(record);
			super.result(data);
		}
		
		public function get record():Record
		{
			return _record;
		}
	}
}