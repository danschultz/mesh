package mesh
{
	import collections.HashMap;
	import collections.HashSet;
	
	import flash.utils.setTimeout;
	
	import operations.Operation;
	import operations.ParallelOperation;
	import operations.SequentialOperation;

	public class Batch
	{
		private var _elements:HashSet = new HashSet();
		private var _entities:HashSet = new HashSet();
		private var _caches:HashMap = new HashMap();
		
		public function Batch()
		{
			
		}
		
		public function add(...elements):Batch
		{
			for each (var element:IPersistable in elements) {
				if (!_elements.contains(element)) {
					element.batch(this);
				}
			}
			_elements.add(element);
			return this;
		}
		
		public function save():Operation
		{
			var operation:SequentialOperation = new SequentialOperation();
			
			var previous:PersistenceCache;
			var batch:ParallelOperation;
			var caches:Array = _caches.values().sortOn("depth", Array.NUMERIC);
			for each (var cache:PersistenceCache in caches) {
				if (previous == null || previous.depth != cache.depth) {
					if (batch != null) {
						operation.add(batch);
					}
					batch = new ParallelOperation();
				}
				
				batch.add(cache.save());
				previous = cache;
			}
			
			if (batch != null) {
				operation.add(batch);
			}
			
			setTimeout(operation.execute, Mesh.DELAY);
			return operation;
		}
		
		public function create(entity:Entity):void
		{
			cache(entity).create(entity);
		}
		
		public function destroy(entity:Entity):void
		{
			cache(entity).destroy(entity);
		}
		
		public function update(entity:Entity):void
		{
			cache(entity).update(entity);
		}
		
		private function cache(entity:Entity):PersistenceCache
		{
			if (!_caches.containsKey(entity.adaptor)) {
				_caches.put(entity.adaptor, new PersistenceCache(entity.descriptor));
			}
			return _caches.grab(entity.adaptor);
		}
	}
}

import collections.HashSet;

import flash.events.Event;

import mesh.Entity;
import mesh.EntityDescription;
import mesh.associations.BelongsToRelationship;
import mesh.associations.Relationship;

import operations.EmptyOperation;
import operations.FactoryOperation;
import operations.FinishedOperationEvent;
import operations.MethodOperation;
import operations.Operation;
import operations.SequentialOperation;

import strings.capitalize;

class PersistenceCache
{
	private var _description:EntityDescription;
	
	private var _create:HashSet = new HashSet();
	private var _destroy:HashSet = new HashSet();
	private var _update:HashSet = new HashSet();
	
	public function PersistenceCache(description:EntityDescription)
	{
		_description = description;
	}
	
	private function countLongestParentPath(description:EntityDescription):int
	{
		var count:int = 0;
		for each (var relationship:Relationship in description.relationships) {
			if (relationship is BelongsToRelationship) {
				count = Math.max(count, countLongestParentPath(EntityDescription.describe(relationship.target)) + 1);
			}
		}
		return count;
	}
	
	public function create(entity:Entity):void
	{
		_create.add(entity);
	}
	
	public function destroy(entity:Entity):void
	{
		_destroy.add(entity);
	}
	
	public function update(entity:Entity):void
	{
		_update.add(entity);
	}
	
	private function createSaveOperation(adaptorFunc:Function, entities:Array, callback:String):Operation
	{
		var before:SequentialOperation = new SequentialOperation();
		var after:SequentialOperation = new SequentialOperation();
		for each (var entity:Entity in entities) {
			before.add( new MethodOperation(entity.callback, "before" + capitalize(callback)) );
			after.add( new MethodOperation(entity.callback, "after" + capitalize(callback)) );
		}
		
		before.addEventListener(FinishedOperationEvent.FINISHED, function(event:Event):void
		{
			trace("before finished");
		});
		
		var factory:FactoryOperation = new FactoryOperation(adaptorFunc, entities);
		factory.addEventListener(FinishedOperationEvent.FINISHED, function(event:Event):void
		{
			trace("adaptor finished");
		});
		
		after.addEventListener(FinishedOperationEvent.FINISHED, function(event:Event):void
		{
			trace("after finished");
		});
		
		return before.then( factory ).then(after);
	}
	
	public function save():Operation
	{
		var saveOperation:Operation = new EmptyOperation();
		if (_create.length > 0) {
			saveOperation = saveOperation.then( createSaveOperation(_description.adaptor.create, _create.toArray(), "save") );
		}
		if (_update.length > 0) {
			saveOperation = saveOperation.then( createSaveOperation(_description.adaptor.update, _update.toArray(), "save") );
		}
		if (_destroy.length > 0) {
			saveOperation = saveOperation.then( createSaveOperation(_description.adaptor.destroy, _destroy.toArray(), "destroy") );
		}
		return saveOperation;
	}
	
	private var _depth:int = -1;
	public function get depth():int
	{
		if (_depth == -1) {
			var visited:HashSet = new HashSet();
			for each (var entity:Entity in _create.toArray().concat(_destroy.toArray()).concat(_update.toArray())) {
				if (!visited.contains(entity.descriptor.entityType)) {
					_depth = Math.max(_depth, countLongestParentPath(entity.descriptor));
					visited.add(entity.descriptor.entityType);
				}
			}
		}
		return _depth;
	}
}