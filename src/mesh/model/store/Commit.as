package mesh.model.store
{
	import collections.HashSet;
	
	import flash.events.EventDispatcher;
	
	import mesh.core.object.copy;
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
		private var _entities:HashSet;
		
		private var _committed:HashSet = new HashSet();
		private var _dependencies:Dependencies = new Dependencies();
		
		/**
		 * Constructor.
		 * 
		 * @param store The store that the commit originates from.
		 * @param entities The snapshots of each entity to commit.
		 */
		public function Commit(store:Store, entities:Array)
		{
			_store = store;
			_entities = new HashSet(entities);
			_snapshots = new Snapshots(entities);
			createDependencies();
		}
		
		/**
		 * Checks if the given entity belongs to this commit.
		 * 
		 * @param entity The entity to check.
		 * @return <code>true</code> if the entity is found.
		 */
		public function contains(entity:Entity):Boolean
		{
			return _entities.contains(entity);
		}
		
		/**
		 * The data source calls this method when an entity was successfully created or updated on
		 * the backend. The data source may also supply an array of data objects. If this argument
		 * is given, the data from each element in the array will be copied to the entity.
		 * 
		 * @param entities The entities that were successful.
		 * @param data A list of data to copy onto each entity.
		 * @param copier A function that copies data from an object to the entity. This method should
		 * 	have the following signature: <code>function(entity:Entity, data:Object):void</code>. If
		 * 	empty, the method will use <code>mesh.core.object.copy()</code>.
		 */
		public function saved(entities:Array, data:Array = null, copier:Function = null):void
		{
			copyData(entities, data, copier);
			completed(entities);
		}
		
		/**
		 * The data source calls this method when an entity was successfully destroyed from the
		 * backend.
		 * 
		 * @param entities The entities that were destroyed.
		 */
		public function destroyed(entities:Array):void
		{
			completed(entities);
		}
		
		/**
		 * The data source calls this method when an entity was successfully committed to
		 * the backend. The data source may also supply an array of data objects. If this argument
		 * is given, the data from each element in the array will be copied to the entity.
		 * 
		 * @param entities The entities that were successful.
		 * @param data A list of data to copy onto each entity.
		 * @param copier A function that copies data from an object to the entity. This method should
		 * 	have the following signature: <code>function(entity:Entity, data:Object):void</code>. If
		 * 	empty, the method will use <code>mesh.core.object.copy()</code>.
		 */
		private function copyData(entities:Array, data:Array = null, copier:Function = null):void
		{
			if (data != null) {
				for (var i:int = 0; i < data.length; i++) {
					if (copier != null) {
						copier(entities[i], data[i]);
					} else {
						copy(data[i], entities[i]);
					}
				}
			}
		}
		
		private function completed(entities:Array):void
		{
			_committed.addAll(entities);
			_operation.completed(entities);
			
			for each (var entity:Entity in entities) {
				entity.synced();
				
				// Notify dependencies that their dependents have been committed, and any foreign keys 
				// should be synced now.
				for each (var depenency:Entity in _dependencies.dependenciesFor(entity)) {
					depenency.synced();
				}
			}
			
			commitDependents(entities);
		}
		
		private function commitDependents(entities:Array):void
		{
			var dependents:HashSet = new HashSet();
			for each (var entity:Entity in entities) {
				dependents.addAll(_dependencies.dependentsFor(entity));
			}
			commit(dependents.toArray());
		}
		
		private function createDependencies():void
		{
			for each (var entity:Entity in _entities) {
				for each (var association:Association in entity.associations) {
					_dependencies.addDependents(entity, association.dependents);
				}
			}
		}
		
		/**
		 * The data source calls this method when an entity failed during a commit to the
		 * backend.
		 * 
		 * @param entities The entities that failed.
		 * @param fault The reason for the failure.
		 */
		public function failed(entities:Array, fault:SourceFault):void
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
		
		private function storeEntities(entities:Array):Array
		{
			return entities.map(function(entity:Entity, ...args):Entity
			{
				return _store.index.findByKey(entity.storeKey);
			});
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
		
		private function commit(entities:Array = null):void
		{
			entities = entities == null ? _entities.toArray() : entities;
			
			// Nothing left commit.
			if (entities.length == 0) {
				return;
			}
			
			var create:Array = entities.filter(function(entity:Entity, ...args):Boolean
			{
				return !_committed.contains(entity) && entity.status.isNew && entity.status.isDirty && _committed.containsAll(_dependencies.dependenciesFor(entity));
			});
			var update:Array = entities.filter(function(entity:Entity, ...args):Boolean
			{
				return !_committed.contains(entity) && entity.status.isPersisted && entity.status.isDirty;
			});
			var destroy:Array = entities.filter(function(entity:Entity, ...args):Boolean
			{
				return !_committed.contains(entity) && entity.status.isDestroyed && entity.status.isDirty;
			});
			
			if (create.length > 0) {
				_store.dataSource.createEach(this, create);
			}
			
			if (update.length > 0) {
				_store.dataSource.updateEach(this, update);
			}
			
			if (destroy.length > 0) {
				_store.dataSource.destroyEach(this, destroy);
			}
		}
		
		/**
		 * The number of entities that need to be committed.
		 */
		public function get count():int
		{
			return _entities.length;
		}
		
		private var _snapshots:Snapshots;
		/**
		 * @copy Snapshots
		 */
		public function get snapshots():Snapshots
		{
			return _snapshots;
		}
	}
}

import collections.HashSet;

import flash.utils.Dictionary;

import mesh.model.Entity;
import mesh.model.source.SourceFault;
import mesh.model.store.Commit;
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
	public function Dependencies()
	{
		
	}
	
	public function addDependents(target:Entity, dependents:Array):void
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
