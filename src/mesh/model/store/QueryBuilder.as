package mesh.model.store
{
	import mesh.model.source.DataSource;

	public class QueryBuilder
	{
		private var _store:Store;
		private var _dataSource:DataSource;
		private var _recordType:Class;
		
		public function QueryBuilder(store:Store, dataSource:DataSource, recordType:Class)
		{
			_store = store;
			_dataSource = dataSource;
			_recordType = recordType;
		}
		
		/**
		 * Generates a new query that fetches all records of a single type.
		 * 
		 * @return A query.
		 */
		public function all():Query
		{
			return new AllQuery(_store, _dataSource, _recordType);
		}
		
		/**
		 * Generates a new query that fetches a single record by its ID.
		 * 
		 * @param id The ID of the record to fetch.
		 * @return A query.
		 */
		public function id(id:Object):Query
		{
			return new FindOneQuery(_store, _dataSource, _recordType, id);
		}
	}
}

import mesh.model.source.DataSource;
import mesh.model.store.Query;
import mesh.model.store.Store;

class FindOneQuery extends Query
{
	private var _id:Object;
	
	public function FindOneQuery(store:Store, dataSource:DataSource, recordType:Class, id:Object)
	{
		super(store, dataSource, recordType);
		_id = id;
	}
}

class FindManyQuery extends Query
{
	public function FindManyQuery(store:Store, dataSource:DataSource, recordType:Class)
	{
		super(store, dataSource, recordType);
	}
}

class AllQuery extends Query
{
	public function AllQuery(store:Store, dataSource:DataSource, recordType:Class)
	{
		super(store, dataSource, recordType);
	}
}