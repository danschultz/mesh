package mesh.model.store
{
	import mesh.core.reflection.newInstance;
	import mesh.mesh_internal;
	import mesh.model.Record;
	import mesh.model.source.DataSource;
	
	use namespace mesh_internal;
	
	public class Store
	{
		public function Store(dataSource:DataSource)
		{
			_records = new RecordIndex(this);
			_data = new DataIndex();
			_dataSource = dataSource;
		}
		
		public function find(...args):*
		{
			// Find an Record by type and ID, i.e. store.find(Person, 1)
			if (args.length == 2) {
				return findRecord(args[0], args[1]);
			}
		}
		
		private function findRecord(type:Class, id:Object):Record
		{
			var record:Record = records.findByTypeAndID(type, id);
			
			// An record for this type and ID doesn't exist yet.
			if (record == null) {
				record = newInstance(type);
				record.id = id;
				new RecordRequest(record, this).execute();
			}
			
			return record;
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
		
		private var _records:RecordIndex;
		internal function get records():RecordIndex
		{
			return _records;
		}
	}
}

import collections.HashSet;

import flash.utils.Dictionary;

import mesh.core.List;
import mesh.mesh_internal;
import mesh.model.Record;
import mesh.model.store.Data;
import mesh.model.store.Store;

use namespace mesh_internal;

class RecordIndex
{
	private var _index:HashSet = new HashSet();
	private var _types:TypeIndex = new TypeIndex();
	private var _store:Store;
	
	public function RecordIndex(store:Store)
	{
		_store = store;
	}
	
	public function add(record:Record):void
	{
		if (!_index.contains(record)) {
			record.store = _store;
			_index.add(record);
			_types.add(record.reflect.clazz, record);
		}
	}
	
	public function findByTypeAndID(type:Class, id:Object):Record
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
	
	public function findByType(type:Class):List
	{
		return _types.findByType(type);
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
			_index[type] = new List();
		}
		_index[type].add(data);
	}
	
	public function findByType(type:Class):List
	{
		return _index[type];
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