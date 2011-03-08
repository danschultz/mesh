package operations
{
	import flash.events.EventDispatcher;
	
	import mx.collections.ArrayList;
	import mx.collections.IList;
	import mx.collections.ListCollectionView;
	
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
			operation.reset();
			items.addItem(operation);
			progress.total += operation.progress.total;
			
			executeAvailable();
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
				if (operation.isFinished) {
					progress.complete -= operation.progress.complete;
				}
				progress.total -= operation.progress.total;
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
					(executing.getItemAt(0) as Operation).reset();
				}
			}
		}
		
		private function executeAvailable():void
		{
			while (executing.length < _simultaneousCount) {
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
		
		private function handleOperationProgress(event:FinishedOperationEvent):void
		{
			
		}
		
		private function handleOperationFinished(event:FinishedOperationEvent):void
		{
			if (event.successful) {
				progress.complete += event.operation.progress.complete;
			}
			
			event.operation.removeEventListener(ProgressOperationEvent.PROGRESS, handleOperationProgress);
			event.operation.removeEventListener(FinishedOperationEvent.FINISHED, handleOperationFinished);
			executeAvailable();
		}
		
		/**
		 * The next operation in the queue to be executed.
		 * 
		 * @return A queued operation, or <code>null</code> if the queue is empty.
		 */
		public function next():Operation
		{
			return Operation( queued().getItemAt(0) );
		}
		
		private var _isRunning:Boolean;
		/**
		 * <code>true</code> if the queue is currently running.
		 */
		public function get isRunning():Boolean
		{
			return _isRunning;
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
		public function queued():IList
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
			if (_progress == null) {
				_progress = new QueueProgress(this);
			}
			return _progress;
		}
	}
}