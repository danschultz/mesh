package mesh.model.source
{
	import mx.utils.ObjectUtil;
	import mesh.model.Record;

	/**
	 * The <code>RecordSnapshot</code> class represents a record at a specific time.
	 * 
	 * @author Dan Schultz
	 */
	public class RecordSnapshot
	{
		/**
		 * Creates a new snapshot from an object.
		 * 
		 * @param record The record to create the snapshot of.
		 */
		public function RecordSnapshot(record:Record)
		{
			_record = record;
			snap();
		}
		
		private function snap():void
		{
			_data = ObjectUtil.copy(record);
		}
		
		private var _data:Object;
		/**
		 * The copied data.
		 */
		public function get data():Object
		{
			return _data;
		}
		
		private var _record:Record;
		/**
		 * The record that this snapshot is based off of.
		 */
		public function get record():Record
		{
			return _record;
		}
	}
}