package mesh.model.source
{
	import mesh.model.Record;
	import mesh.model.RecordState;
	import mesh.model.associations.Association;
	import mesh.model.associations.AssociationCollection;
	
	import mx.utils.ObjectUtil;

	/**
	 * The <code>RecordSnapshot</code> class represents a record at a specific time.
	 * 
	 * @author Dan Schultz
	 */
	public class Snapshot
	{
		/**
		 * Creates a new snapshot from an object.
		 * 
		 * @param record The record to create the snapshot of.
		 */
		public function Snapshot(record:Record)
		{
			_record = record;
			snap();
		}
		
		private function snap():void
		{
			_data = ObjectUtil.copy(record);
			
			for each (var association:Association in record.associations) {
				if (association is AssociationCollection) {
					var collection:AssociationCollection = (association as AssociationCollection);
					_data[association.property] = new AssociationCollectionSnapshot(collection.toArray(), collection.added, collection.removed);
				}
			}
			
			_state = record.state;
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
		
		private var _state:RecordState;
		/**
		 * The state of the record when the snapshot was created.
		 */
		public function get state():RecordState
		{
			return _state;
		}
	}
}