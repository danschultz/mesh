package mesh
{
	import collections.HashMap;
	import collections.HashSet;
	import collections.ISet;
	
	import flash.utils.Dictionary;
	
	import functions.closure;
	
	import mesh.adaptors.ServiceAdaptor;
	import mesh.associations.AssociationProxy;
	import mesh.associations.BelongsToRelationship;
	import mesh.associations.Relationship;
	
	import operations.FactoryOperation;
	import operations.Operation;
	import operations.ParallelOperation;
	import operations.SequentialOperation;
	
	public class SaveBuilder
	{
		private var _entities:Array;
		private var _entitiesToSave:ISet;
		private var _entitiesToRemove:ISet;
		
		public function SaveBuilder(entities:Array)
		{
			_entities = entities;
			_entitiesToSave = findEntitiesToSave();
			_entitiesToRemove = findEntitiesToRemove();
		}
		
		public function build():Operation
		{
			var operation:SequentialOperation = new SequentialOperation();
			var graph:Array = buildRelationshipGraph();
			for (var i:int = 0; i < graph.length; i++) {
				if (graph[i] != null) {
					operation.add(buildSaveOperation(graph[i]));
				}
			}
			return operation.then(buildRemoveOperation(_entitiesToRemove.toArray()));
		}
		
		private function buildRelationshipGraph():Array
		{
			var result:Array = [];
			for each (var entity:Entity in _entitiesToSave) {
				var length:int = countLongestParentPath(entity);
				
				if (result[length] == null) {
					result[length] = [];
				}
				
				result[length].push(entity);
			}
			return result;
		}
		
		private function countLongestParentPath(entity:Object):int
		{
			var count:int = 0;
			for each (var relationship:Relationship in entity.descriptor.relationships) {
				if (relationship is BelongsToRelationship) {
					var parent:Object = entity[relationship.property];
					if (parent != null && _entitiesToSave.contains(parent)) {
						count = Math.max(count, countLongestParentPath(parent) + 1);
					}
				}
			}
			return count;
		}
		
		private function findEntitiesToRemove():ISet
		{
			var result:HashSet = new HashSet();
			for each (var entity:Entity in _entities) {
				result.addAll(entity.findRemovedEntities());
			}
			return result;
		}
		
		private function findEntitiesToSave():ISet
		{
			var result:HashSet = new HashSet();
			for each (var entity:Entity in _entities) {
				result.addAll(entity.findDirtyEntities());
			}
			return result;
		}
		
		private function buildSaveOperation(entities:Array):Operation
		{
			var map:HashMap = mapEntitiesByAdaptor(entities);
			var operation:ParallelOperation = new ParallelOperation();
			for each (var adaptor:ServiceAdaptor in map.keys()) {
				var entitiesToCreate:Array = map.grab(adaptor).filter(closure(function(entity:Entity):Boolean
				{
					return entity.isNew;
				}));
				var entitiesToSave:Array = map.grab(adaptor).filter(closure(function(entity:Entity):Boolean
				{
					return !entity.isNew && entity.hasPropertyChanges;
				}));
				
				var beforeSave:SequentialOperation = new SequentialOperation();
				var afterSave:SequentialOperation = new SequentialOperation();
				for each (var entityToSave:Entity in entitiesToCreate.concat(entitiesToSave)) {
					beforeSave.add(entityToSave.callbacksAsOperation("beforeSave"));
					afterSave.add(entityToSave.callbacksAsOperation("afterSave"));
				}
				
				var saveOperation:Operation = beforeSave;
				if (entitiesToCreate.length > 0) {
					saveOperation = saveOperation.then( new FactoryOperation(adaptor.create, entitiesToCreate) );
				}
				if (entitiesToSave.length > 0) {
					saveOperation = saveOperation.then( new FactoryOperation(adaptor.update, entitiesToSave) );
				}
				saveOperation = saveOperation.then(afterSave);
				
				operation.add(saveOperation);
			}
			
			return operation;
		}
		
		private function buildRemoveOperation(entities:Array):Operation
		{
			var map:HashMap = mapEntitiesByAdaptor(entities);
			var operation:ParallelOperation = new ParallelOperation();
			for each (var adaptor:ServiceAdaptor in map.keys()) {
				var beforeDestroy:SequentialOperation = new SequentialOperation();
				var afterDestroy:SequentialOperation = new SequentialOperation();
				
				for each (var entity:Entity in map.grab(adaptor)) {
					beforeDestroy.add(entity.callbacksAsOperation("beforeDestroy"));
					afterDestroy.add(entity.callbacksAsOperation("afterDestroy"));
				}
				
				operation.add(beforeDestroy.then(adaptor.destroy(map.grab(adaptor)).then(afterDestroy)));
			}
			return operation;
		}
		
		private function mapEntitiesByAdaptor(entities:Array):HashMap
		{
			var map:HashMap = new HashMap();
			
			for each (var entity:Entity in entities) {
				var adaptor:ServiceAdaptor = entity.descriptor.adaptor;
				if (!map.containsKey(adaptor)) {
					map.put(adaptor, []);
				}
				map.grab(adaptor).push(entity);
			}
			
			return map;
		}
	}
}