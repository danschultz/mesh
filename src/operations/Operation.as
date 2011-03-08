package operations
{
	import flash.events.EventDispatcher;
	import flash.utils.getQualifiedClassName;
	
	import mx.events.PropertyChangeEvent;
	
	/**
	 * Dispatched when the execution of an operation has been canceled.
	 */
	[Event(name="canceled", type="operations.OperationEvent")]
	
	/**
	 * Dispatched when the execution of an operation has been queued.
	 */
	[Event(name="queued", type="operations.OperationEvent")]
	
	/**
	 * Dispatched after the execution of an operation has started.
	 */
	[Event(name="afterExecute", type="operations.OperationEvent")]
	
	/**
	 * Dispatched before the execution of an operation is about to start.
	 */
	[Event(name="beforeExecute", type="operations.OperationEvent")]
	
	/**
	 * Dispatched when the operation has progressed during its execution.
	 */
	[Event(name="progress", type="operations.ProgressOperationEvent")]
	
	/**
	 * Dispatched when either an error or fault has occurred during the execution
	 * of an operation.
	 */
	[Event(name="fault", type="operations.FaultOperationEvent")]
	
	/**
	 * Dispatched when the execution of an operation has finished. Clients can check
	 * if an operation finished successfully by accessing the events 
	 * <code>successful</code> property.
	 */
	[Event(name="finished", type="operations.FinishedOperationEvent")]
	
	/**
	 * Dispatched a result was received during the execution of an operation. This event
	 * contains the parsed result data.
	 */
	[Event(name="result", type="operations.ResultOperationEvent")]
	
	/**
	 * The <code>Operation</code> is a base class representing an arbitrary atomic request.
	 * Requests can include a simple function call to a class, or more complex operations
	 * that require a network call.
	 * 
	 * @author Dan Schultz
	 */
	public class Operation extends EventDispatcher
	{
		private static const QUEUED:int = 0;
		private static const EXECUTING:int = 1;
		private static const FINISHED:int = 2;
		
		private var _state:int = QUEUED;
		
		/**
		 * Constructor.
		 */
		public function Operation()
		{
			super();
		}
		
		/**
		 * Cancels the request, if it can be canceled.
		 */
		final public function cancel():void
		{
			if (isExecuting) {
				cancelRequest();
				fireCanceled();
				finish(false);
			}
		}
		
		/**
		 * Performs the actual cancelling of the request. This method is intended
		 * to be overridden by sub-classes and should not be called directly.
		 */
		protected function cancelRequest():void
		{
			
		}
		
		private function changeState(newState:int):void
		{
			_state = newState;
			dispatchEvent( PropertyChangeEvent.createUpdateEvent(this, null, null, null) );
		}
		
		/**
		 * Executes the request.
		 */
		final public function execute():void
		{
			if (isQueued) {
				changeState(EXECUTING);
				fireBeforeExecute();
				
				if (isExecuting) {
					executeRequest();
					fireAfterExecute();
				}
			}
		}
		
		/**
		 * Performs the execution for this type of request. This method is intended
		 * to be overridden by sub-classes and should not be called directly.
		 */
		protected function executeRequest():void
		{
			
		}
		
		/**
		 * Chains the given operation to execute while this operation is executing.
		 * 
		 * <p>
		 * Combining operations allows multiple operations to behave as a single operation.
		 * For instance, clients could add a single <code>FinishedOperationEvent.FINISHED</code>
		 * listener to the combined operation to see when all operations have finished
		 * executing.
		 * </p>
		 * 
		 * <p>
		 * <strong>Example:</strong> Combining multiple operations together:
		 * 
		 * <listing version="3.0">
		 * var str:String = "Hello World";
		 * var operation1:MethodOperation = new MethodOperation(str.substr, 0, 5);
		 * var operation2:MethodOperation = new MethodOperation(str.substr, 6, 5);
		 * var operation3:MethodOperation = new MethodOperation(str.substr, 0, str.length);
		 * 
		 * var chained:Operation = operation1.during(operation2).then(operation3));
		 * chained.addEventListener(FinishedOperationEvent.FINISHED, handleChainedOperationFinished);
		 * chained.execute();
		 * 
		 * function handleChainedOperationFinished(event:FinishedOperationEvent):void
		 * {
		 * 	trace("all operations have finished");
		 * }
		 * </listing>
		 * </p>
		 * 
		 * @param operation The operation to execute while this operation is executing.
		 * @return A chained operation.
		 */
		public function during(operation:Operation):Operation
		{
			return new ParallelOperation([this, operation]);
		}
		
		/**
		 * Called by sub-classes to indicate that an error or fault occurred during 
		 * the execution of the event. Calling this method will mark the operation
		 * as finished.
		 * 
		 * @param summary A simple description of the fault.
		 * @param detail A more detailed description of the fault.
		 */
		public function fault(summary:String, detail:String = ""):void
		{
			if (isExecuting) {
				fireFault(summary, detail);
				_hasErrored = true;
				finish(false);
			}
		}
		
		/**
		 * Called by sub-classes to indicate that this operation is finished. This 
		 * method is automatically called when clients invoke either the <code>fault()</code>
		 * or <code>result()</code> methods, but may need to be invoked by sub-classes
		 * in specific cases which do not use these two methods. Do not call this method
		 * after invoking <code>result()</code> or <code>fault()</code>.
		 * 
		 * @param successful <code>true</code> if the operation is successful.
		 */
		final protected function finish(successful:Boolean):void
		{
			if (isExecuting) {
				changeState(FINISHED)
				progressed(unitsTotal);
				fireFinished(successful);
			}
		}
		
		private function fireCanceled():void
		{
			if (hasEventListener(OperationEvent.CANCELED)) {
				dispatchEvent( new OperationEvent(OperationEvent.CANCELED) );
			}
		}
		
		private function fireQueued():void
		{
			if (hasEventListener(OperationEvent.QUEUED)) {
				dispatchEvent( new OperationEvent(OperationEvent.QUEUED) );
			}
		}
		
		private function fireAfterExecute():void
		{
			if (hasEventListener(OperationEvent.AFTER_EXECUTE)) {
				dispatchEvent( new OperationEvent(OperationEvent.AFTER_EXECUTE) );
			}
		}
		
		private function fireBeforeExecute():void
		{
			if (hasEventListener(OperationEvent.BEFORE_EXECUTE)) {
				dispatchEvent( new OperationEvent(OperationEvent.BEFORE_EXECUTE) );
			}
		}
		
		private function fireProgress():void
		{
			if (hasEventListener(ProgressOperationEvent.PROGRESS)) {
				dispatchEvent( new ProgressOperationEvent(ProgressOperationEvent.PROGRESS) );
			}
		}
		
		private function fireFault(summary:String, detail:String = ""):void
		{
			if (hasEventListener(FaultOperationEvent.FAULT)) {
				dispatchEvent( new FaultOperationEvent(summary, detail) );
			}
		}
		
		private function fireResult(data:Object):void
		{
			if (hasEventListener(ResultOperationEvent.RESULT)) {
				dispatchEvent( new ResultOperationEvent(data) );
			}
		}
		
		private function fireFinished(successful:Boolean):void
		{
			if (hasEventListener(FinishedOperationEvent.FINISHED)) {
				dispatchEvent( new FinishedOperationEvent(successful) );
			}
		}
		
		/**
		 * Called when result data is received during the execution of the operation.
		 * This method is called during the <code>result()</code> method, and allows
		 * sub-classes to parse and modify the original result data.
		 * 
		 * @param data The result data.
		 * @return The parsed result data.
		 */
		protected function parseResult(data:Object):Object
		{
			return data;
		}
		
		/**
		 * Called by sub-classes to indicate the progress of the operation.
		 * 
		 * @param unitsComplete The number of units completed.
		 */
		final protected function progressed(unitsComplete:Number):void
		{
			_progress.complete = unitsComplete;
			fireProgress();
		}
		
		/**
		 * Resets the operation to its queued state. If the operation is executing, it will be
		 * canceled. If the operation has finished its errors, result data, and progress will
		 * be reset.
		 */
		final public function queue():void
		{
			if (isExecuting) {
				cancelRequest();
			}
			
			progress.complete = 0;
			_hasErrored = false;
			
			if (!isQueued) {
				changeState(QUEUED);
				fireQueued();
			}
		}
		
		/**
		 * Called by a sub-class to indicate that a result was received during the 
		 * execution of the operation.
		 * 
		 * <p>
		 * When a result is received, sub-classes can choose to parse the data by 
		 * overriding the <code>parseResult()</code> method. If an error occurs
		 * during parsing, a fault is generated.
		 * <p>
		 * 
		 * <p>
		 * Calling this method will mark the operation as finished.
		 * </p>
		 * 
		 * @param data The unparsed result data.
		 */
		protected function result(data:Object):void
		{
			if (isExecuting) {
				try {
					fireResult(parseResult(data));
					finish(true);
				} catch (e:Error) {
					fault(e.toString(), e.getStackTrace());
				}
			}
		}
		
		/**
		 * Chains the given operation to execute after this operation has finished.
		 * 
		 * <p>
		 * Combining operations allows multiple operations to behave as a single operation.
		 * For instance, clients could add a single <code>FinishedOperationEvent.FINISHED</code>
		 * listener to the combined operation to see when all operations have finished
		 * executing.
		 * </p>
		 * 
		 * <p>
		 * <strong>Example:</strong> Combining multiple operations together:
		 * 
		 * <listing version="3.0">
		 * var str:String = "Hello World";
		 * var operation1:MethodOperation = new MethodOperation(str.substr, 0, 5);
		 * var operation2:MethodOperation = new MethodOperation(str.substr, 6, 5);
		 * var operation3:MethodOperation = new MethodOperation(str.substr, 0, str.length);
		 * 
		 * var chained:Operation = operation1.during(operation2).then(operation3));
		 * chained.addEventListener(FinishedOperationEvent.FINISHED, handleChainedOperationFinished);
		 * chained.execute();
		 * 
		 * function handleChainedOperationFinished(event:FinishedOperationEvent):void
		 * {
		 * 	trace("all operations have finished");
		 * }
		 * </listing>
		 * </p>
		 * 
		 * @param operation The operation to execute after this operation has finished.
		 * @return A chained operation.
		 */
		public function then(operation:Operation):Operation
		{
			return new SequentialOperation([this, operation]);
		}
		
		/**
		 * @private
		 */
		override public function toString():String
		{
			var qualifiedName:String = getQualifiedClassName(this);
			var classNameParts:Array = qualifiedName.split("::");
			return classNameParts.length > 1 ? classNameParts[1] : classNameParts[0];
		}
		
		[Bindable(event="propertyChange")]
		/**
		 * Indicates whether the request is currently executing.
		 */
		final public function get isExecuting():Boolean
		{
			return _state == EXECUTING;
		}
		
		[Bindable(event="propertyChange")]
		/**
		 * Indicates whether the request is finished, either successfully or unsuccessfully.
		 */
		final public function get isFinished():Boolean
		{
			return _state == FINISHED;
		}
		
		[Bindable(event="propertyChange")]
		/**
		 * Indicates whether the request is idle and ready to be executed.
		 */
		final public function get isQueued():Boolean
		{
			return _state == QUEUED;
		}
		
		[Bindable(event="propertyChange")]
		/**
		 * Indicates whether the request has finished, and hasn't errored.
		 */
		final public function get isSuccessful():Boolean
		{
			return isFinished && !hasErrored;
		}
		
		private var _hasErrored:Boolean;
		[Bindable(event="propertyChange")]
		/**
		 * <code>true</code> if this operation errored during its execution.
		 */
		final public function get hasErrored():Boolean
		{
			return _hasErrored;
		}
		
		private var _progress:Progress;
		[Bindable(event="progress")]
		/**
		 * Information about the progress of this operation.
		 */
		public function get progress():Progress
		{
			if (_progress == null) {
				_progress = new Progress();
				_progress.total = unitsTotal;
			}
			return _progress;
		}
		
		/**
		 * The number of units needed to complete this operation.
		 */
		protected function get unitsTotal():Number
		{
			return 1;
		}
	}
}