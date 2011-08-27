package mesh.operations
{
	/**
	 * The timeout for a network operation.
	 * 
	 * @author Dan Schultz
	 */
	public class Timeout
	{
		private var _operation:NetworkOperation;
		private var _scale:Number;
		
		public function Timeout(milliseconds:Number, operation:NetworkOperation)
		{
			_scale = 1;
			_value = milliseconds;
			_operation = operation;
		}
		
		/**
		 * Sets the timeout to be interpreted as milliseconds.
		 * 
		 * @return The network operation.
		 */
		public function milliseconds():NetworkOperation
		{
			return _operation;
		}
		
		/**
		 * Sets the timeout to be interpreted as minutes.
		 * 
		 * @return The network operation.
		 */
		public function minutes():NetworkOperation
		{
			_scale = 60000;
			return _operation;
		}
		
		/**
		 * Sets the timeout to be interpreted as seconds.
		 * 
		 * @return The network operation.
		 */
		public function seconds():NetworkOperation
		{
			_scale = 1000;
			return _operation;
		}
		
		public function toString():String
		{
			return (value/1000).toString() + " seconds";
		}
		
		public function valueOf():Object
		{
			return value;
		}
		
		private var _value:Number;
		public function get value():Number
		{
			return _value / _scale;
		}
	}
}