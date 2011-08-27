package mesh.operations
{
	/**
	 * Stores the retries for a network operation.
	 * 
	 * @author Dan Schultz.
	 */
	public class Attempt
	{
		private var _operation:NetworkOperation;
		private var _delays:Array = [0];
		
		public function Attempt(maxAttempts:int, operation:NetworkOperation)
		{
			_maxAttempts = Math.max(1, maxAttempts);
			_operation = operation;
		}
		
		public function getDelayForAttemptInMilliseconds(attempt:int):Number
		{
			attempt = Math.min(_delays.length, attempt);
			return _delays[attempt-1] * 1000;
		}
		
		/**
		 * Sets the delay, in seconds, for each retry attempt. The delay for the first
		 * retry is the first argument, the delay for the second retry is the second
		 * argument and so on. To set the delay for all attempts, pass in a single
		 * argument.
		 * 
		 * @param delays The delays for each retry attempt.
		 * @return The operation.
		 */
		public function withDelay(... delays):NetworkOperation
		{
			_delays = delays;
			return _operation;
		}
		
		/**
		 * Removes the delay between each retry attempt.
		 * 
		 * @return The operation.
		 */
		public function withoutDelay():NetworkOperation
		{
			_delays = [0];
			return _operation;
		}
		
		private var _maxAttempts:int;
		public function get maxAttempts():int
		{
			return _maxAttempts;
		}
	}
}