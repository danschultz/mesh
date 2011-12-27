package mesh.model.store
{
	/**
	 * The <code>SyncState</code> class represents the state of the store data in 
	 * relation to the data's source.
	 * 
	 * @author Dan Schultz
	 */
	public class SyncState
	{
		/**
		 * A data state that represents the data is in the process of syncing with the 
		 * data's source.
		 */
		public static const BUSY:SyncState = new SyncState(2);
		
		/**
		 * A data state that represents the data is out-of-sync with the data's source.
		 */
		public static const DIRTY:SyncState = new SyncState(1);
		
		/**
		 * A data state that represents the data is synced with the data's source.
		 */
		public static const SYNCED:SyncState = new SyncState(0);
		
		/**
		 * Constructor.
		 * 
		 * @param value The state's value.
		 */
		public function SyncState(value:int)
		{
			_value = value;
		}
		
		/**
		 * Checks if this state is the same as another state.
		 * 
		 * @param obj The object to check.
		 * @return <code>true</code> if the states are equal.
		 */
		public function equals(obj:Object):Boolean
		{
			return (obj is SyncState) && value == (obj as SyncState).value;
		}
		
		private var _value:int;
		/**
		 * The state's value.
		 */
		internal function get value():int
		{
			return _value;
		}
	}
}