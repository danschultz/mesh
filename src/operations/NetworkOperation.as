package operations
{
	import flash.errors.IllegalOperationError;
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
			addEventListener(OperationEvent.AFTER_EXECUTE, handleOperationExecuted);
		}
		
		private function attemptExecution(attempt:int):void
		{
			_attemptsCount = attempt;
			
			if (attempt > _attempt.maxAttempts) {
				throw new IllegalOperationError(this + " cannot attempt anymore requests.");
			}
			
			_attemptTimer.delay = _attempt.getDelayForAttempt(attempt);
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
			stopTimeoutTimer();
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
		final override public function fault(summary:String, detail:String = ""):void
		{
			stopTimeoutTimer();
			super.fault(summary, detail);
		}
		
		private function handleAttemptTimerComplete(event:TimerEvent):void
		{
			request();
		}
		
		private function handleOperationExecuted(event:OperationEvent):void
		{
			_attemptsCount = 0;
			startTimeoutTimer();
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
		 * @inheritDoc
		 */
		final override protected function result(data:Object):void
		{
			stopTimeoutTimer();
			super.result(data);
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

import operations.NetworkOperation;

class Timeout
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

class Attempt
{
	private var _operation:NetworkOperation;
	private var _delays:Array = [0];
	
	public function Attempt(maxAttempts:int, operation:NetworkOperation)
	{
		_maxAttempts = Math.max(1, maxAttempts);
		_operation = operation;
	}
	
	public function getDelayForAttempt(attempt:int):Number
	{
		attempt = Math.min(_delays.length, attempt);
		return _delays[attempt-1];
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