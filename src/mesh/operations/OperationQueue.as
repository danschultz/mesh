package mesh.operations
{
	import flash.events.EventDispatcher;
	
	import mx.collections.ArrayList;
	import mx.collections.IList;
	import mx.collections.ListCollectionView;
	
	/**
	 * Dispatched when the queue has started.
	 */
	[Event(name="started", type="mesh.operations.OperationQueueEvent")]
	
	/**
	 * Dispatched when the queue receives a progress event from one of its operations.
	 */
	[Event(name="progress", type="mesh.operations.OperationQueueEvent")]
	
	/**
	 * Dispatched when the queue has finished all of its operations.
	 */
	[Event(name="idle", type="mesh.operations.OperationQueueEvent")]
	
	/**
	 * Dispatched when the queue has been paused.
	 */
	[Event(name="paused", type="mesh.operations.OperationQueueEvent")]
	
	/**
	 * An <code>OperationQueue</code> manages the execution of a set of <code>Operation</code>s.
	 * This class allows you to queue operations that are computationally expensive, or take large
	 * amounts of time, such as uploading.
	 * 
	 * <p>
	 * Operations are queued by passing in the operation to <code>queue()</code>. This method adds 
	 * the operation to the end of the queue. Once started, the queue will execute each operation 
	 * until the queue is empty. Multiple operations can be executed simultaneously by passing in a 
	 * <code>simultaneousCount</code> to the queue's constructor. Operations can be added and removed
	 * from the queue while it's running.
	 * <p>
	 * 
	 * <p>
	 * Users can monitor the progress of the queue by using the queue's <code>progress</code>
	 * property. This object contains how many units of work that the queue has completed, and how
	 * many units of work total are needed to complete the whole queue.
	 * </p>
	 * 
	 * <p>
	 * The queue also maintains bindable lists that your views can use to display which operations
	 * are queued, which operations have finished, and which operations have errored. You can pass
	 * these lists to the data provider of any Spark or MX list control.
	 * </p>
	 * 
	 * @author Dan Schultz
	 */
	public class OperationQueue extends EventDispatcher
	{
		private var _simultaneousCount:int;
		
		/**
		 * Constructor.
		 */
		public function OperationQueue(simultaneousCount:int = 1)
		{
			super();
			_simultaneousCount = simultaneousCount;
			_progress = new QueueProgress(this);
		}
		
		/**
		 * Adds an operation to the end of the queue to be executed. If the operation is
		 * executing, it will be requeued.
		 * 
		 * @param operation The operation to queue.
		 */
		public function queue(operation:Operation):void
		{
			remove(operation);
			operation.queue();
			items.addItem(operation);
			progress.total += operation.progress.total;
			executeAvailable();
			
			operation.addEventListener(OperationEvent.CANCELED, handleOperationCanceled);
			fireProgress();
		}
		
		/**
		 * Removes an operation from the queue. If the operation is executing, it will be 
		 * canceled.
		 * 
		 * @param operation The operation to remove.
		 */
		public function remove(operation:Operation):void
		{
			if (_items.removeItem(operation)) {
				operation.removeEventListener(OperationEvent.CANCELED, handleOperationCanceled);
				operation.cancel();
				
				if (operation.isSuccessful) {
					_progress.confirmed -= operation.progress.complete;
				}
				progress.total -= operation.progress.total;
				fireProgress();
			}
		}
		
		/**
		 * Removes all operation from the queue. Any operations that are executing will be
		 * canceled.
		 */
		public function clear():void
		{
			while (items.length > 0) {
				remove(Operation( items.getItemAt(0) ));
			}
		}
		
		/**
		 * Starts the queue.
		 */
		public function start():void
		{
			if (!isRunning) {
				_isRunning = true;
				fireStarted();
				executeAvailable();
			}
		}
		
		/**
		 * Pauses the queue.
		 */
		public function pause():void
		{
			if (isRunning) {
				_isRunning = false;
				
				while (executing.length > 0) {
					(executing.getItemAt(0) as Operation).queue();
				}
				
				firePaused();
			}
		}
		
		/**
		 * The next operation in the queue to be executed.
		 * 
		 * @return A queued operation, or <code>null</code> if the queue is empty.
		 */
		public function next():Operation
		{
			return queued.length > 0 ? Operation( queued.getItemAt(0) ) : null;
		}
		
		private function executeAvailable():void
		{
			while (isRunning && next() != null && executing.length < _simultaneousCount) {
				execute(next());
			}
		}
		
		private function execute(operation:Operation):void
		{
			if (!operation.isQueued) {
				throw new ArgumentError("Attempted to execute non-queued operation.");
			}
			
			operation.addEventListener(ProgressOperationEvent.PROGRESS, handleOperationProgress);
			operation.addEventListener(FinishedOperationEvent.FINISHED, handleOperationFinished);
			operation.execute();
		}
		
		private function handleOperationCanceled(event:OperationEvent):void
		{
			remove(event.operation);
		}
		
		private function handleOperationProgress(event:ProgressOperationEvent):void
		{
			fireProgress();
		}
		
		private function handleOperationFinished(event:FinishedOperationEvent):void
		{
			if (event.successful) {
				_progress.confirmed += event.operation.progress.complete;
			}
			
			event.operation.removeEventListener(ProgressOperationEvent.PROGRESS, handleOperationProgress);
			event.operation.removeEventListener(FinishedOperationEvent.FINISHED, handleOperationFinished);
			executeAvailable();
			
			fireProgress();
			if (executing.length == 0) {
				fireIdle();
			}
		}
		
		private function fireStarted():void
		{
			fireEvent(OperationQueueEvent.STARTED);
		}
		
		private function fireProgress():void
		{
			fireEvent(OperationQueueEvent.PROGRESS);
		}
		
		private function firePaused():void
		{
			fireEvent(OperationQueueEvent.PAUSED);
		}
		
		private function fireIdle():void
		{
			fireEvent(OperationQueueEvent.IDLE);
		}
		
		private function fireEvent(type:String):void
		{
			if (hasEventListener(type)) {
				dispatchEvent( new OperationQueueEvent(type) );
			}
		}
		
		private var _isRunning:Boolean;
		/**
		 * <code>true</code> if the queue is currently running.
		 */
		public function get isRunning():Boolean
		{
			return _isRunning;
		}
		
		/**
		 * <code>true</code> if the queue is running and isn't executing any operations.
		 */
		public function get isIdle():Boolean
		{
			return isRunning && executing.length == 0;
		}
		
		private var _errored:ListCollectionView;
		/**
		 * The set of <code>Operation</code>s that have executed and errored.
		 */
		public function errored():IList
		{
			if (_errored == null) {
				_errored = new ListCollectionView(items);
				_errored.filterFunction = function(operation:Operation):Boolean
				{
					return operation.hasErrored;
				};
				_errored.refresh();
			}
			return _errored;
		}
		
		private var _executing:ListCollectionView;
		/**
		 * The set of <code>Operation</code>s that are currently executing.
		 */
		public function get executing():IList
		{
			if (_executing == null) {
				_executing = new ListCollectionView(items);
				_executing.filterFunction = function(operation:Operation):Boolean
				{
					return operation.isExecuting;
				};
				_executing.refresh();
			}
			return _executing;
		}
		
		private var _queued:ListCollectionView;
		/**
		 * The set of <code>Operation</code>s that are awaiting to be executed.
		 */
		public function get queued():IList
		{
			if (_queued == null) {
				_queued = new ListCollectionView(items);
				_queued.filterFunction = function(operation:Operation):Boolean
				{
					return operation.isQueued;
				};
				_queued.refresh();
			}
			return _queued;
		}
		
		private var _successful:ListCollectionView;
		/**
		 * The set of <code>Operation</code>s have finished successfully.
		 */
		public function get successful():IList
		{
			if (_successful == null) {
				_successful = new ListCollectionView(items);
				_successful.filterFunction = function(operation:Operation):Boolean
				{
					return operation.isSuccessful;
				};
				_successful.refresh();
			}
			return _successful;
		}
		
		private var _items:ArrayList = new ArrayList();
		/**
		 * The set of all operations to execute.
		 */
		public function get items():IList
		{
			return _items;
		}
		
		private var _progress:QueueProgress;
		/**
		 * The progress of the queue.
		 */
		public function get progress():Progress
		{
			return _progress;
		}
	}
}