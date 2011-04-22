package mesh.operations
{
	/**
	 * The <code>Progress</code> class contains information about the progress of an
	 * operation. It holds the number of units that have completed, and the total number
	 * of units needed to complete the operation.
	 * 
	 * @author Dan Schultz
	 */
	public class Progress
	{
		/**
		 * Constructor.
		 * 
		 * @param total The total units needed to complete.
		 */
		public function Progress()
		{
			
		}
		
		/**
		 * Returns the percentage as a string.
		 * 
		 * @return A string.
		 */
		public function toString():String
		{
			var percentage:Number = complete/total;
			return percentage.toString() + (!isNaN(percentage) ? "%" : "");
		}
		
		private var _complete:Number = 0;
		/**
		 * The number of units that have completed.
		 */
		public function get complete():Number
		{
			return _complete;
		}
		public function set complete(value:Number):void
		{
			_complete = value;
		}
		
		private var _total:Number = 0;
		/**
		 * The total number of units to complete the operation.
		 */
		public function get total():Number
		{
			return _total;
		}
		public function set total(value:Number):void
		{
			_total = value;
		}
	}
}