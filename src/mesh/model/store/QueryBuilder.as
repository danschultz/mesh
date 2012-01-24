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
		public function find(id:Object):Query
		{
			return new FindQuery(_store, _recordType, id);
		}
		
		/**
		 * Generates a new query that fetches all records of a single type.
		 * 
		 * @return A query.
		 */
		public function findAll():Query
		{
			return new FindAllQuery(_store, _recordType);
		}
	}
}

import mesh.model.store.Query;
import mesh.model.store.Store;

class FindQuery extends Query
{
	private var _id:Object;
	
	public function FindQuery(store:Store, recordType:Class, id:Object)
	{
		super(store, recordType);
		_id = id;
	}
}

class FindAllQuery extends Query
{
	public function FindAllQuery(store:Store, recordType:Class)
	{
		super(store, recordType);
	}
}