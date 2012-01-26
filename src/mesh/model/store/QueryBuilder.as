package mesh.model.store
{
	public class QueryBuilder
	{
		private var _store:Store;
		private var _recordType:Class;
		
		public function QueryBuilder(store:Store, recordType:Class)
		{
			_store = store;
			_recordType = recordType;
		}
		
		/**
		 * Generates a new query that fetches a single record by its ID.
		 * 
		 * @param id The ID of the record to fetch.
		 * @return A query.
		 */
		public function find(id:Object):*
		{
			return new FindQuery(_store, _recordType, id).execute();
		}
		
		/**
		 * Generates a new query that fetches all records of a single type.
		 * 
		 * @return A query.
		 */
		public function findAll():*
		{
			return new FindAllQuery(_store, _recordType).execute();
		}
	}
}

import mesh.core.reflection.newInstance;
import mesh.mesh_internal;
import mesh.model.Record;
import mesh.model.store.Data;
import mesh.model.store.Query;
import mesh.model.store.ResultsList;
import mesh.model.store.Store;

use namespace mesh_internal;

class FindQuery extends Query
{
	private var _id:Object;
	
	public function FindQuery(store:Store, recordType:Class, id:Object)
	{
		super(store, recordType);
		_id = id;
	}
	
	override public function execute():*
	{
		var record:Record = store.records.find(recordType).byId(_id);
		
		// The record doesn't belong to the store. We need to retrieve it from the data source.
		if (record == null) {
			record = store.materialize( new Data({id:_id}, recordType) );
		}
		
		return record;
	}
}

class FindAllQuery extends Query
{
	private var _results:ResultsList;
	
	public function FindAllQuery(store:Store, recordType:Class)
	{
		super(store, recordType);
	}
	
	override public function execute():*
	{
		if (_results == null) {
			_results = new ResultsList(store, store.records.find(recordType).all(), store.dataSource.retrieveAll(recordType));
		}
		return _results;
	}
}