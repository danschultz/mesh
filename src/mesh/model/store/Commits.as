package mesh.model.store
{
	import collections.HashSet;
	
	import flash.events.Event;
	import flash.utils.ByteArray;
	
	import mesh.core.array.intersection;
	import mesh.operations.FaultOperationEvent;
	import mesh.operations.FinishedOperationEvent;
	import mesh.operations.OperationQueue;

	/**
	 * The <code>Commits</code> class is responsible for keeping a linear history of each commit 
	 * that the data store has requested. The class also manages the queueing of commits, and 
	 * rolling back the store if a commit fails.
	 * 
	 * <p>
	 * When the store requests its changes to be committed, a <code>Commit</code> object is created 
	 * that contains a snapshot of each dirty entity, and is put into a commit queue. Only a single 
	 * commit can be persisted at a time. After each successful commit, the next commit is executed 
	 * until the queue is empty.
	 * </p>
	 * 
	 * <p>
	 * If a commit fails to persist, the queue is halted until a rollback is performed. It's the
	 * responsibility of the application to listen for a failed commit and execute the rollback. If
	 * a rollback is performed, the store is put back into the state of the last successful commit.
	 * </p>
	 * 
	 * @author Dan Schultz
	 */
	public class Commits
	{
		private var _store:Store;
		private var _changes:HashSet;
		
		private var _queue:OperationQueue;
		private var _commits:Array = [];
		
		/**
		 * Constructor.
		 * 
		 * @param store The data store.
		 * @param changes The set of all pending entity changes to be committed.
		 */
		public function Commits(store:Store, changes:HashSet)
		{
			_store = store;
			_changes = changes;
			
			_queue = new OperationQueue(1);
			_queue.start();
		}
		
		private function cleanupCommit(commit:Commit):void
		{
			commit.removeEventListener(FaultOperationEvent.FAULT, handleCommitFailedEvent);
			commit.removeEventListener(FinishedOperationEvent.FINISHED, handleCommitFinishedEvent);
		}
		
		/**
		 * Creates a commit that will persist entities that have changed since the last commit.
		 * By default, this method commits all entities that have changed. You may optionally 
		 * pass in a subset of entities to be committed.
		 * 
		 * @param entities The entities to commit.
		 */
		public function commit(entities:Array = null):void
		{
			entities = (entities == null || entities.length == 0) ? _changes.toArray() : intersection(entities, _changes.toArray());
			_changes.removeAll(entities);
			queue( new Commit(_store, snapshot(entities)) );
		}
		
		private function commitFailed(commit:Commit):void
		{
			cleanupCommit(commit);
			_failed = commit;
			_queue.pause();
		}
		
		private function commitFinished(commit:Commit):void
		{
			cleanupCommit(commit);
			_checkpoint = commit;
		}
		
		private function handleCommitFinishedEvent(event:Event):void
		{
			commitFinished(Commit( event.target ));
		}
		
		private function handleCommitFailedEvent(event:Event):void
		{
			commitFailed(Commit( event.target ));
		}
		
		private function queue(commit:Commit):void
		{
			commit.addEventListener(FaultOperationEvent.FAULT, handleCommitFailedEvent);
			commit.addEventListener(FinishedOperationEvent.FINISHED, handleCommitFinishedEvent);
			
			_commits.unshift(commit);
			commit.queue(_queue);
		}
		
		private function snapshot(entities:Array):Array
		{
			var snapshot:ByteArray = new ByteArray();
			snapshot.writeObject(entities);
			snapshot.position = 0;
			
			var copied:Array = snapshot.readObject();
			var len:int = entities.length;
			for (var i:int = 0; i < len; i++) {
				copied[i].storeKey = entities[i].storeKey;
			}
			
			return copied;
		}
		
		private var _checkpoint:Commit;
		/**
		 * The last successful commit of the store.
		 */
		public function get checkpoint():Commit
		{
			return _checkpoint;
		}
		
		private var _failed:Commit;
		/**
		 * The commit that failed.
		 */
		public function get failed():Commit
		{
			return _failed;
		}
	}
}