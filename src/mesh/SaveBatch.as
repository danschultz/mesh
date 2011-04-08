package mesh
{
	import collections.HashMap;
	import collections.HashSet;
	
	import flash.errors.IllegalOperationError;
	import flash.utils.setTimeout;
	
	import mesh.operations.Operation;
	import mesh.operations.ParallelOperation;
	import mesh.operations.SequentialOperation;
	
	public class SaveBatch
	{
		private var _elements:HashSet = new HashSet();
		private var _entities:HashSet = new HashSet();
		private var _caches:HashMap = new HashMap();
		
		public function SaveBatch()
		{
			
		}
		
		public function add(...elements):SaveBatch
		{
			for each (var element:* in elements) {
				if (element is Array) {
					add.apply(null, element);
					continue;
				}
				
				if (!_elements.contains(element)) {
					element.batch(this);
				}
				_elements.add(element);
			}
			return this;
		}
		
		public function build(validate:Boolean = true):Operation
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
				
				batch.add(cache.save(validate));
				previous = cache;
			}
			
			if (batch != null) {
				operation.add(batch);
			}
			return operation;
		}
		
		public function save(validate:Boolean = true):Operation
		{
			var operation:Operation = build(validate);
			setTimeout(operation.execute, Mesh.DELAY);
			return operation;
		}
		
		public function create(entity:Entity):void
		{
			throwIfMissingServiceAdaptor(entity);
			cache(entity).create(entity);
		}
		
		public function destroy(entity:Entity):void
		{
			throwIfMissingServiceAdaptor(entity);
			cache(entity).destroy(entity);
		}
		
		public function update(entity:Entity):void
		{
			throwIfMissingServiceAdaptor(entity);
			cache(entity).update(entity);
		}
		
		private function cache(entity:Entity):PersistenceCache
		{
			if (!_caches.containsKey(entity.adaptor)) {
				_caches.put(entity.adaptor, new PersistenceCache(entity.descriptor));
			}
			return _caches.grab(entity.adaptor);
		}
		
		private function throwIfMissingServiceAdaptor(entity:Entity):void
		{
			if (entity.adaptor == null) {
				throw new IllegalOperationError(entity + " is missing a service adaptor.");
			}
		}
	}
}

import collections.HashSet;

import mesh.Entity;
import mesh.EntityDescription;
import mesh.associations.BelongsToRelationship;
import mesh.associations.AssociationDefinition;
import mesh.core.string.capitalize;

import mesh.operations.EmptyOperation;
import mesh.operations.FactoryOperation;
import mesh.operations.MethodOperation;
import mesh.operations.Operation;
import mesh.operations.SequentialOperation;

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
		for each (var relationship:AssociationDefinition in description.relationships) {
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
	
	private function createSaveOperation(adaptorFunc:Function, entities:Array, callback:String, validate:Boolean):Operation
	{
		var before:SequentialOperation = new SequentialOperation();
		var after:SequentialOperation = new SequentialOperation();
		for each (var entity:Entity in entities) {
			before.add( new MethodOperation(entity.callback, "before" + capitalize(callback)) );
			before.add( new MethodOperation(checkValidations, entity, validate) );
			after.add( new MethodOperation(entity.callback, "after" + capitalize(callback)) );
		}
		
		return before.then( new FactoryOperation(adaptorFunc, entities) ).then(after);
	}
	
	public function save(validate:Boolean):Operation
	{
		var saveOperation:Operation = new EmptyOperation();
		if (_create.length > 0) {
			saveOperation = saveOperation.then( createSaveOperation(_description.adaptor.create, _create.toArray(), "save", validate) );
		}
		if (_update.length > 0) {
			saveOperation = saveOperation.then( createSaveOperation(_description.adaptor.update, _update.toArray(), "save", validate) );
		}
		if (_destroy.length > 0) {
			saveOperation = saveOperation.then( createSaveOperation(_description.adaptor.destroy, _destroy.toArray(), "destroy", false) );
		}
		return saveOperation;
	}
	
	private function checkValidations(entity:Entity, validate:Boolean):void
	{
		if (validate && entity.isInvalid()) {
			throw new Error(entity + " has errors");
		}
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