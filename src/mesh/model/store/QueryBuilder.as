package mesh.model.store
{
	import mesh.model.source.DataSource;

	public class QueryBuilder
	{
		private var _dataSource:DataSource;
		private var _records:Records;
		private var _recordType:Class;
		
		public function QueryBuilder(dataSource:DataSource, records:Records, recordType:Class)
		{
			_dataSource = dataSource;
			_records = records;
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
			return new FindQuery(_dataSource, _records, _recordType, id).execute();
		}
		
		/**
		 * Generates a new query that fetches all records of a single type.
		 * 
		 * @return A result list.
		 */
		public function findAll():*
		{
			return new FindAllQuery(_dataSource, _records, _recordType).execute();
		}
		
		/**
		 * Returns a new result list that contains the records that meet the given conditions.
		 * 
		 * @param conditions The conditions for the record.
		 * @return A result list.
		 */
		public function where(conditions:Object):*
		{
			return new WhereQuery(_dataSource, _records, _recordType, conditions).execute();
		}
	}
}

import mesh.mesh_internal;
import mesh.model.Record;
import mesh.model.source.DataSource;
import mesh.model.store.Data;
import mesh.model.store.Query;
import mesh.model.store.Records;
import mesh.model.store.ResultsList;
import mesh.model.store.Store;

import mx.collections.ListCollectionView;

use namespace mesh_internal;

class FindQuery extends Query
{
	private var _id:Object;
	
	public function FindQuery(dataSource:DataSource, records:Records, recordType:Class, id:Object)
	{
		super(dataSource, records, recordType);
		_id = id;
	}
	
	override public function execute():*
	{
		var record:Record = records.find(recordType).byId(_id);
		
		// The record doesn't belong to the store. We need to retrieve it from the data source.
		if (record == null) {
			record = records.materialize( new Data({id:_id}, recordType) );
		}
		
		return record;
	}
}

class FindAllQuery extends Query
{
	private var _results:ResultsList;
	
	public function FindAllQuery(dataSource:DataSource, records:Records, recordType:Class)
	{
		super(dataSource, records, recordType);
	}
	
	override public function execute():*
	{
		if (_results == null) {
			_results = new ResultsList(records, records.find(recordType).all(), dataSource.retrieveAll(recordType));
		}
		return _results;
	}
}

class WhereQuery extends Query
{
	private var _results:ResultsList;
	private var _conditions:Object;
	
	public function WhereQuery(dataSource:DataSource, records:Records, recordType:Class, conditions:Object)
	{
		super(dataSource, records, recordType);
		_conditions = conditions;
	}
	
	override public function execute():*
	{
		if (_results == null) {
			var collection:ListCollectionView = new ListCollectionView(records.find(recordType).all());
			collection.filterFunction = function(record:Record):Boolean
			{
				for (var property:String in _conditions) {
					if (record[property] != _conditions[property]) {
						return false;
					}
				}
				return true;
			};
			collection.refresh();
			_results = new ResultsList(records, collection, dataSource.search(recordType, _conditions));
		}
		return _results;
	}
}