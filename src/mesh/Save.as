package mesh
{
	import collections.HashMap;
	import collections.HashSet;

	public class Save
	{
		private var _elements:HashSet = new HashSet();
		private var _entities:HashSet = new HashSet();
		private var _caches:HashMap = new HashMap();
		
		public function Save(...elements)
		{
			for each (var element:* in elements) {
				include(element);
			}
		}
		
		public function save(block:Function = null):void
		{
			block(this);
			
			for each (var entity:Entity in _entities) {
				entity.determineSaveOperation(this);
			}
		}
		
		public function include(element:*):void
		{
			if (element is Entity) {
				_entities.add(element);
			}
			_elements.add(element);
			element.include(this);
		}
		
		public function exclude(element:*):void
		{
			if (element is Entity) {
				_entities.remove(element);
			}
			_elements.remove(element);
			element.exclude(this);
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

import mesh.Entity;
import mesh.EntityDescription;

import operations.EmptyOperation;
import operations.FactoryOperation;
import operations.Operation;

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
	
	public function save():Operation
	{
		var saveOperation:Operation = new EmptyOperation();
		if (_create.length > 0) {
			saveOperation = saveOperation.then( new FactoryOperation(_description.adaptor.create, _create.toArray()) );
		}
		if (_update.length > 0) {
			saveOperation = saveOperation.then( new FactoryOperation(_description.adaptor.update, _update.toArray()) );
		}
		if (_destroy.length > 0) {
			saveOperation = saveOperation.then( new FactoryOperation(_description.adaptor.destroy, _destroy.toArray()) );
		}
		return saveOperation;
	}
}