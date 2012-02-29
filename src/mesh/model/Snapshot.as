package mesh.model
{
	import flash.utils.ByteArray;

	/**
	 * The <code>Snapshot</code> class represents an object at a specific time.
	 * 
	 * @author Dan Schultz
	 */
	public class Snapshot
	{
		/**
		 * Creates a new snapshot from an object.
		 * 
		 * @param origin The object to create the snapshot of.
		 */
		public function Snapshot(origin:Object)
		{
			_origin = origin;
			snap();
		}
		
		private function snap():void
		{
			var copier:ByteArray = new ByteArray();
			copier.writeObject(origin);
			copier.position = 0;
			_data = copier.readObject();
		}
		
		private var _data:Object;
		/**
		 * The copied data.
		 */
		public function get data():Object
		{
			return _data;
		}
		
		private var _origin:Object;
		/**
		 * The object that this snapshot is based off of.
		 */
		public function get origin():Object
		{
			return _origin;
		}
	}
}