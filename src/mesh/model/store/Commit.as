package mesh.model.store
{
	import collections.HashSet;
	
	import flash.events.EventDispatcher;
	
	import mesh.model.Entity;
	import mesh.model.associations.Association;
	import mesh.model.source.SourceFault;
	import mesh.operations.FaultOperationEvent;
	import mesh.operations.FinishedOperationEvent;
	import mesh.operations.Operation;
	import mesh.operations.OperationQueue;
	
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
		
		private var _dependencies:Dependencies;
		private var _snapshots:Snapshots;
		
		/**
		 * Constructor.
		 * 
		 * @param store The store that the commit originates from.
		 * @param entities The snapshots of each entity to commit.
		 */
		public function Commit(store:Store, entities:Array)
		{
			_store = store;
			_snapshots = new Snapshots(this, entities);
			_dependencies = new Dependencies(this, entities);
		}
		
		/**
		 * Checks if the given entity can be committed. There are situations when an entity has to wait
		 * for its parent entity to finish committing before it can be committed. 
		 * 
		 * @param entity The entity to check.
		 * @return <code>true</code> if the entity can be committed.
		 */
		public function isCommittable(entity:Entity):Boolean
		{
			var snapshot:Snapshot = _snapshots.findByEntity(entity);
			
			if (snapshot.isCommitted) {
				return false;
			}
			
			if (!snapshot.status.isNew) {
				return true;
			}
			
			for each (var dependency:Entity in _dependencies.dependenciesFor(entity)) {
				if (!_snapshots.findByEntity(dependency).isCommitted) {
					return false;
				}
			}
			
			return true;
		}
		
		/**
		 * Checks if the given entity belongs to this commit.
		 * 
		 * @param entity The entity to check.
		 * @return <code>true</code> if the entity is found.
		 */
		public function contains(entity:Entity):Boolean
		{
			return _snapshots.contains(entity.storeKey);
		}
		
		/**
		 * The data source calls this method when a snapshot's entity was successfully created, 
		 * updated or destroyed in the data source. The data source may also supply an array of 
		 * data objects. If this argument is given, the data from each element in the array will 
		 * be copied to the entity.
		 * 
		 * @param snapshots The snapshots that were committed.
		 * @param ids A list of IDs to copy onto each entity of the snapshots.
		 */
		public function committed(snapshots:Array, ids:Array = null):void
		{
			_snapshots.committed(snapshots, ids);
			_operation.completed(snapshots);
			
			for each (var snapshot:Snapshot in snapshots) {
				snapshot.entity.synced();
				
				// Notify the owners of this entity that it's been committed and that the foreign keys
				// are synced.
				for each (var depenency:Entity in _dependencies.dependenciesFor(snapshot.entity)) {
					depenency.synced();
				}
			}
			
			commitDependents(snapshots);
		}
		
		private function commit(keys:Array = null):void
		{
			_snapshots.commit(_store.dataSource, keys);
		}
		
		private function commitDependents(snapshots:Array):void
		{
			var dependents:HashSet = new HashSet();
			for each (var snapshot:Snapshot in snapshots) {
				dependents.addAll(_dependencies.dependentsFor(snapshot.entity));
			}
			
			commit(dependents.toArray().map(function(entity:Entity, ...args):Object
			{
				return entity.storeKey;
			}));
		}
		
		/**
		 * The data source calls this method when a snapshot's entity failed during a commit to the
		 * backend.
		 * 
		 * @param snapshots The snapshots that failed.
		 * @param fault The reason for the failure.
		 */
		public function failed(snapshots:Array, fault:SourceFault):void
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
			commit();
		}
		
		/**
		 * The number of entities that need to be committed.
		 */
		public function get count():int
		{
			return _snapshots.length;
		}
	}
}

import collections.HashSet;

import flash.utils.Dictionary;

import mesh.model.Entity;
import mesh.model.associations.Association;
import mesh.model.source.SourceFault;
import mesh.model.store.Commit;
import mesh.model.store.Snapshot;
import mesh.operations.Operation;

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
	public function failed(reason:SourceFault):void
	{
		fault(reason.summary, reason.details, reason.code);
	}
	
	private var _progressCounter:int = 0;
	/**
	 * Called by the commit to indicate that its entities have been successfully committed.
	 * 
	 * @param snapshots The snapshots that were successful.
	 */
	public function completed(snapshots:Array):void
	{
		_progressCounter += snapshots.length;
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

/**
 * An index of commit dependencies. A dependency defines that an entity cannot be committed
 * until its dependency is committed.
 * 
 * @author Dan Schultz
 */
class Dependencies
{
	private var _entityToDependencies:Dictionary = new Dictionary();
	private var _entityToDependents:Dictionary = new Dictionary();
	
	/**
	 * Constructor.
	 */
	public function Dependencies(commit:Commit, entities:Array)
	{
		build(commit, entities);
	}
	
	private function addDependents(target:Entity, dependents:Array):void
	{
		if (_entityToDependents[target] == null) {
			_entityToDependents[target] = new HashSet();
		}
		_entityToDependents[target].addAll(dependents);
		
		for each (var dependent:Entity in dependents) {
			addDependency(dependent, target);
		}
	}
	
	private function addDependency(target:Entity, dependency:Entity):void
	{
		if (_entityToDependencies[target] == null) {
			_entityToDependencies[target] = new HashSet();
		}
		_entityToDependencies[target].add(dependency);
	}
	
	private function build(commit:Commit, entities:Array):void
	{
		for each (var entity:Entity in entities) {
			if (entity.status.isNew) {
				for each (var association:Association in entity.associations) {
					if (association.isMaster) {
						addDependents(entity, association.entities.filter(function(entity:Entity, index:int, array:Array):Boolean
						{
							return commit.contains(entity);
						}));
					}
				}
			}
		}
	}
	
	/**
	 * Returns the dependencies for an entity.
	 * 
	 * @param entity The entity.
	 * @return A list of entities.
	 */
	public function dependenciesFor(entity:Entity):Array
	{
		return _entityToDependencies[entity] != null ? _entityToDependencies[entity].toArray() : [];
	}
	
	/**
	 * Returns the dependents for an entity.
	 * 
	 * @param entity The entity.
	 * @return A list of entities.
	 */
	public function dependentsFor(entity:Entity):Array
	{
		return _entityToDependents[entity] != null ? _entityToDependents[entity].toArray() : [];
	}
}
