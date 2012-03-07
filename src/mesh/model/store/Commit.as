package mesh.model.store
{
	import flash.events.EventDispatcher;
	
	import mesh.model.source.DataSource;
	import mesh.model.source.IPersistenceResponder;
	import mesh.model.source.Snapshots;
	import mesh.operations.Operation;
	
	public class Commit extends EventDispatcher
	{
		private var _dataSource:DataSource;
		private var _snapshots:Snapshots;
		
		public function Commit(dataSource:DataSource, records:Array)
		{
			super();
			_dataSource = dataSource;
			_snapshots = Snapshots.create(records);
		}
		
		public function persist():void
		{
			if (!operation.isExecuting) {
				operation.queue();
				operation.execute();
			}
		}
		
		private var _operation:Operation;
		public function get operation():Operation
		{
			if (_operation == null) {
				_operation = new DataSourcePersistenceOperation(_dataSource, _snapshots);
			}
			return _operation;
		}
	}
}

import flash.utils.Dictionary;

import mesh.model.source.DataSource;
import mesh.model.source.IPersistenceResponder;
import mesh.model.source.Snapshot;
import mesh.model.source.Snapshots;
import mesh.operations.Operation;

class DataSourcePersistenceOperation extends Operation implements IPersistenceResponder
{
	private var _dataSource:DataSource;
	private var _snapshots:Snapshots;
	
	private var _persistedSnapshots:Dictionary;
	private var _saveCounter:int;
	
	public function DataSourcePersistenceOperation(dataSource:DataSource, snapshots:Snapshots)
	{
		super();
		_dataSource = dataSource;
		_snapshots = snapshots;
	}
	
	/**
	 * @inheritDoc
	 */
	public function saved(snapshot:Snapshot, id:Object = null):void
	{
		snapshot.record.sycned(id);
		
		if (_persistedSnapshots[snapshot] == null && _snapshots.contains(snapshot)) {
			_persistedSnapshots[snapshot] = true;
			_saveCounter++;
		}
		
		if (_saveCounter == _snapshots.length) {
			finish(true);
		}
	}
	
	/**
	 * @inheritDoc
	 */
	public function failed(summary:String, detail:String = "", code:String = ""):void
	{
		fault(summary, detail, code);
	}
	
	override protected function executeRequest():void
	{
		super.executeRequest();
		
		_saveCounter = 0;
		_persistedSnapshots = new Dictionary();
		
		_dataSource.createEach(this, _snapshots.create);
		_dataSource.updateEach(this, _snapshots.update);
		_dataSource.destroyEach(this, _snapshots.destroy);
	}
}