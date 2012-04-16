package mesh.model.source
{
	import mesh.core.List;
	
	public class AssociationCollectionSnapshot extends List
	{
		public function AssociationCollectionSnapshot(source:Array, added:Array, removed:Array)
		{
			super(source);
			_added = added;
			_removed = removed;
		}
		
		private var _added:Array;
		/**
		 * The records that have been added to the association.
		 */
		public function get added():Array
		{
			return _added.concat();
		}
		
		private var _removed:Array;
		/**
		 * The records that have been removed from the association.
		 */
		public function get removed():Array
		{
			return _removed.concat();
		}
	}
}