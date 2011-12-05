package mesh.operations
{
	import flash.errors.IllegalOperationError;
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.utils.Timer;

	/**
	 * A base class for asynchronous operations that make a network connection. Network
	 * operations support timeouts and retries of failed requests. Clients can change the
	 * time interval for the timeout and also the time intervals between each retry 
	 * attempt.
	 * 
	 * <p>
	 * When implementing a network operation class, sub-classes must override the 
	 * <code>request()</code> method to perform the actual network call. The 
	 * <code>executeRequest()</code> method is marked as final, and handles the logic for
	 * delaying a request.
	 * </p>
	 * 
	 * @author Dan Schultz
	 */
	public class NetworkOperation extends Operation
	{
		private var _attempt:Attempt;
		private var _timeout:Timeout;
		
		private var _timeoutTimer:Timer;
		private var _attemptTimer:Timer;
		
		/**
		 * Constructor.
		 */
		public function NetworkOperation()
		{
			super();
			
			_attempt = new Attempt(1, this);
			_timeout = new Timeout(0, this);
			
			_attemptTimer = new Timer(0, 1);
			_attemptTimer.addEventListener(TimerEvent.TIMER_COMPLETE, handleAttemptTimerComplete);
			
			// sets the attempt count back to 0
			addEventListener(OperationEvent.BEFORE_EXECUTE, handleBeforeExecute);
			addEventListener(FinishedOperationEvent.FINISHED, handleFinished);
		}
		
		override protected function progressed(unitsComplete:Number):void
		{
			_timeoutTimer.reset();
			_timeoutTimer.start();
		}
		
		private function attemptExecution(attempt:int):void
		{
			_attemptsCount = attempt;
			
			if (attempt > _attempt.maxAttempts) {
				throw new IllegalOperationError(this + " cannot attempt anymore requests.");
			}
			
			_attemptTimer.delay = _attempt.getDelayForAttemptInMilliseconds(attempt);
			_attemptTimer.start();
		}
		
		/**
		 * Sets the number of attempts for this network operation. This method will return a
		 * <code>Attempt</code> object where clients can change the amount of time between
		 * each retry. An operation must have at least one attempt. Passing in a values less
		 * than 1 will be reset to 1.
		 * 
		 * <p>
		 * <strong>Example:</strong> Setting the retry attempts and their delays for a network 
		 * operation:
		 * 
		 * <listing version="3.0">
		 * var delayedOperation:NetworkOperation = new NetworkOperation();
		 * delayedOperation.attempts(3).withDelay(15, 30, 60);
		 * 
		 * var undelayedOperation:NetworkOperation = new NetworkOperation();
		 * undelayedOperation.attempts(3).withoutDelay();
		 * </listing>
		 * </p>
		 * 
		 * @param count The number of retries to attempt before failing.
		 * @return A retry object to set the delay intervals.
		 */
		final public function attempts(count:Number):Attempt
		{
			count = Math.max(1, count);
			_attempt = new Attempt(count, this);
			return _attempt;
		}
		
		/**
		 * @inheritDoc
		 */
		override protected function cancelRequest():void
		{
			stopAttempt();
		}
		
		/**
		 * @inheritDoc
		 */
		final override protected function executeRequest():void
		{
			super.executeRequest();
			attemptExecution(attemptsCount+1);
		}
		
		/**
		 * @inheritDoc
		 */
		final override public function fault(summary:String, detail:String = "", code:String = ""):void
		{
			if (attemptsCount < _attempt.maxAttempts) {
				executeRequest();
			} else {
				super.fault(summary, detail, code);
			}
		}
		
		private function handleAttemptTimerComplete(event:TimerEvent):void
		{
			startTimeoutTimer();
			request();
		}
		
		private function handleBeforeExecute(event:OperationEvent):void
		{
			_attemptsCount = 0;
			startTimeoutTimer();
		}
		
		private function handleFinished(event:OperationEvent):void
		{
			stopTimeoutTimer();
		}
		
		private function handleTimeoutTimerComplete(event:TimerEvent):void
		{
			fault(this + " timed out after " + _timeout);
		}
		
		/**
		 * The method to be overridden by sub-classes to perform the network call.
		 */
		protected function request():void
		{
			
		}
		
		/**
		 * Called by sub-classes to retry a failed request. If no more retry attempts can be made,
		 * the operation fails and dispatches a <code>FaultOperationEvent.FAULT</code> event.
		 * 
		 * @param summary A simple description of the fault.
		 * @param detail A more detailed description of the fault.
		 */
		protected function retry(summary:String, detail:String = ""):void
		{
			if (attemptsCount < _attempt.maxAttempts) {
				executeRequest();
			} else {
				fault(summary, detail);
			}
		}
		
		private function startTimeoutTimer():void
		{
			stopTimeoutTimer();
			
			if (_timeout.value > 0) {
				_timeoutTimer = new Timer(_timeout.value, 1);
				_timeoutTimer.addEventListener(TimerEvent.TIMER_COMPLETE, handleTimeoutTimerComplete);
				_timeoutTimer.start();
			}
		}
		
		private function stopAttempt():void
		{
			_attemptTimer.stop();
		}
		
		private function stopTimeoutTimer():void
		{
			if (_timeoutTimer != null) {
				_timeoutTimer.stop();
				_timeoutTimer.removeEventListener(TimerEvent.TIMER_COMPLETE, handleTimeoutTimerComplete);
				_timeoutTimer = null;
			}
		}
		
		/**
		 * Sets a timeout for this network operation. This method will return a <code>Timeout</code>
		 * object where you can change the unit of time for the timeout.
		 * 
		 * <p>
		 * <strong>Example:</strong> Setting the timeout for a network operation:
		 * 
		 * <listing version="3.0">
		 * var operation:NetworkOperation = new NetworkOperation();
		 * operation.timeoutAfter(5).minutes();
		 * </listing>
		 * </p>
		 * 
		 * @param value The interval for the timeout.
		 * @return A timeout object to set the unit of time.
		 */
		final public function timeoutAfter(value:Number):Timeout
		{
			_timeout = new Timeout(value, this);
			return _timeout;
		}
		
		private var _attemptsCount:int;
		/**
		 * The number of times that this operation has attempted to execute successfully.
		 */
		public function get attemptsCount():int
		{
			return _attemptsCount;
		}
	}
}
