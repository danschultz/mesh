package mesh.model.store
{
	/**
	 * The <code>DataState</code> class encapsulates the state of the data for a store key in
	 * the store, in relation to the data's source.
	 * 
	 * @author Dan Schultz
	 */
	public class DataState
	{
		/**
		 * Constructor.
		 */
		public function DataState(value:int)
		{
			_value = value;
		}
		
		/**
		 * Checks if two states are equal.
		 * 
		 * @param obj The object to check.
		 * @return <code>true</code> if the two states are equal.
		 */
		public function equals(obj:Object):Boolean
		{
			return obj is DataState ? obj.value == value : false;
		}
		
		private var _value:int;
		/**
		 * The internal value for this state.
		 */
		public function get value():int
		{
			return _value;
		}
	}
}