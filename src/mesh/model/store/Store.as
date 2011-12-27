package mesh.model.store
{
	import mesh.model.source.DataSource;

	public class Store
	{
		private var _index:Index = new Index();
		
		public function Store(dataSource:DataSource)
		{
			_dataSource = dataSource;
		}
		
		public function add(...data):Store
		{
			_index.addAll(data);
			return this;
		}
		
		public function remove(...data):Store
		{
			_index.removeAll(data);
			return this;
		}
		
		private var _dataSource:DataSource;
		public function get dataSource():DataSource
		{
			return _dataSource;
		}
	}
}

import collections.HashSet;

class Index extends HashSet
{
	public function Index()
	{
		super();
	}
}