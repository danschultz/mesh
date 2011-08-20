package mesh.model.store
{
	import flash.events.EventDispatcher;
	
	import mesh.model.Entity;
	import mesh.operations.FaultOperationEvent;
	import mesh.operations.FinishedOperationEvent;
	import mesh.operations.Operation;
	import mesh.operations.OperationQueue;
	
	import mx.rpc.Fault;
	
	/**
	 * Dispatched when the commit has successfully committed all of its entities.
	 */
	[Event(name="finished", type="mesh.operations.FinishedOperationEvent")]
	
	/**
	 * Dispatched when the commit failed.
	 */
	[Event(name="fault", type="mesh.operations.FaultOperationEvent")]
	
	/**
	 * The <code>Commit</code> class encapsulates the state of each dirty entity that needs
	 * to be synced with the data source.
	 * 
	 * @author Dan Schultz
	 */
	public class Commit extends EventDispatcher
	{
		private var _store:Store;
		private var _entities:Array;
		
		/**
		 * Constructor.
		 * 
		 * @param store The store that the commit originates from.
		 * @param entities The snapshots of each entity to commit.
		 */
		public function Commit(store:Store, entities:Array)
		{
			_store = store;
			_entities = entities;
		}
		
		/**
		 * The data source calls this method when an entity was successfully committed to
		 * the backend.
		 * 
		 * @param entities The entities that were successful.
		 */
		public function completed(entities:Array):void
		{
			_operation.completed(entities);
		}
		
		/**
		 * The data source calls this method when an entity failed during a commit to the
		 * backend.
		 * 
		 * @param entities The entities that failed.
		 * @param fault The reason for the failure.
		 */
		public function failed(entities:Array, fault:Fault):void
		{
			_operation.failed(fault);
		}
		
		private function handleOperationFinishedEvent(event:FinishedOperationEvent):void
		{
			dispatchEvent(event.clone());
		}
		
		private function handleOperationFaultEvent(event:FaultOperationEvent):void
		{
			dispatchEvent(event.clone());
		}
		
		private var _operation:CommitOperation;
		/**
		 * Adds the commit to a queue.
		 */
		public function queue(queue:OperationQueue):void
		{
			if (_operation == null) {
				_operation = new CommitOperation(this);
				_operation.addEventListener(FinishedOperationEvent.FINISHED, handleOperationFinishedEvent);
				_operation.addEventListener(FaultOperationEvent.FAULT, handleOperationFaultEvent);
			}
			queue.queue(_operation);
		}
		
		/**
		 * Called by the commits operation to perform the commit.
		 */
		public function save():void
		{
			_store.dataSource.commit(this);
		}
		
		/**
		 * The number of entities that need to be committed.
		 */
		public function get count():int
		{
			return _entities.length;
		}
		
		private var _create:Array;
		/**
		 * The set of entities in this store that need to be created in the backend.
		 */
		public function get create():Array
		{
			if (_create == null) {
				_create = _entities.filter(function(entity:Entity, ...args):Boolean
				{
					return entity.isNew && entity.isDirty;
				});
			}
			return _create.concat();
		}
		
		private var _update:Array;
		/**
		 * The set of entities in this store that need to be updated in the backend.
		 */
		public function get update():Array
		{
			if (_update == null) {
				_update = _entities.filter(function(entity:Entity, ...args):Boolean
				{
					return entity.isPersisted && entity.isDirty;
				});
			}
			return _update.concat();
		}
		
		private var _destroy:Array;
		/**
		 * The set of entities in this store that need to be destroyed in the backend.
		 */
		public function get destroy():Array
		{
			if (_destroy == null) {
				_destroy = _entities.filter(function(entity:Entity, ...args):Boolean
				{
					return entity.isDestroyed && entity.isDirty;
				});
			}
			return _destroy.concat();
		}
	}
}

import mesh.model.store.Commit;
import mesh.operations.Operation;

import mx.rpc.Fault;

/**
 * An operation that maintains the state of a commit.
 * 
 * @author Dan Schultz
 */
class CommitOperation extends Operation
{
	private var _commit:Commit;
	
	/**
	 * Constructor.
	 * 
	 * @param commit The commit.
	 */
	public function CommitOperation(commit:Commit)
	{
		super();
		_commit = commit;
	}
	
	/**
	 * @inheritDoc
	 */
	override protected function executeRequest():void
	{
		_commit.save();
	}
	
	/**
	 * Called by the commit to indicate that it failed.
	 * 
	 * @param fault The reason for the failure.
	 */
	public function failed(reason:Fault):void
	{
		fault(reason.faultString, reason.faultDetail, reason.faultCode);
	}
	
	private var _progressCounter:int = 0;
	/**
	 * Called by the commit to indicate that its entities have been successfully committed.
	 * 
	 * @param entities The entities that were successful.
	 */
	public function completed(entities:Array):void
	{
		_progressCounter += entities.length;
		progressed(_progressCounter);
		
		if (progress.complete == progress.total) {
			finish(true);
		}
	}
	
	/**
	 * @inheritDoc
	 */
	override protected function get unitsTotal():Number
	{
		return _commit.count;
	}
}
