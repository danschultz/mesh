package mesh.model.store
{
	import mesh.core.reflection.newInstance;
	import mesh.mesh_internal;
	import mesh.model.Entity;
	import mesh.model.source.DataSource;
	
	use namespace mesh_internal;
	
	public class Store
	{
		public function Store(dataSource:DataSource)
		{
			_entities = new EntityIndex(this);
			_data = new DataIndex();
			_dataSource = dataSource;
		}
		
		public function find(...args):*
		{
			// Find an Entity by type and ID, i.e. store.find(Person, 1)
			if (args.length == 2) {
				return findEntity(args[0], args[1]);
			}
		}
		
		private function findEntity(type:Class, id:Object):Entity
		{
			var entity:Entity = entities.findByTypeAndID(type, id);
			
			// An entity for this type and ID doesn't exist yet.
			if (entity == null) {
				entity = newInstance(type);
				entity.id = id;
				new EntityRequest(entity, this).execute();
			}
			
			return entity;
		}
		
		private var _data:DataIndex;
		internal function get data():DataIndex
		{
			return _data;
		}
		
		private var _dataSource:DataSource;
		internal function get dataSource():DataSource
		{
			return _dataSource;
		}
		
		private var _entities:EntityIndex;
		internal function get entities():EntityIndex
		{
			return _entities;
		}
	}
}

import collections.ArraySequence;
import collections.HashSet;

import flash.utils.Dictionary;

import mesh.mesh_internal;
import mesh.model.Entity;
import mesh.model.store.Data;
import mesh.model.store.Store;

use namespace mesh_internal;

class EntityIndex
{
	private var _index:HashSet = new HashSet();
	private var _types:TypeIndex = new TypeIndex();
	private var _store:Store;
	
	public function EntityIndex(store:Store)
	{
		_store = store;
	}
	
	public function add(entity:Entity):void
	{
		if (!_index.contains(entity)) {
			entity.store = _store;
			_index.add(entity);
			_types.add(entity.reflect.clazz, entity);
		}
	}
	
	public function findByTypeAndID(type:Class, id:Object):Entity
	{
		return _types.findByTypeAndID(type, id);
	}
}

class DataIndex
{
	private var _index:HashSet = new HashSet();
	private var _types:TypeIndex = new TypeIndex();
	
	public function DataIndex()
	{
		
	}
	
	public function add(data:Data):void
	{
		if (!_index.contains(data)) {
			_index.add(data);
			_types.add(data.type, data);
		}
	}
	
	public function findByTypeAndID(type:Class, id:Object):Data
	{
		return _types.findByTypeAndID(type, id);
	}
}

class TypeIndex
{
	private var _index:Dictionary = new Dictionary();
	
	public function TypeIndex()
	{
		
	}
	
	public function add(type:Class, data:Object):void
	{
		if (_index[type] == null) {
			_index[type] = new ArraySequence();
		}
		_index[type].add(data);
	}
	
	public function findByTypeAndID(type:Class, id:Object):*
	{
		for each (var obj:Object in _index[type]) {
			if (obj.id == id) {
				return obj;
			}
		}
		return null;
	}
}