package mesh.model.store
{
	import mesh.model.source.DataSource;
	import mesh.model.source.IPersistenceResponder;
	import mesh.model.source.Snapshots;
	import mesh.operations.FaultOperationEvent;
	import mesh.operations.FinishedOperationEvent;
	import mesh.operations.Operation;
	
	/**
	 * The <code>Commit</code> class is responsible for persisting records from the store to
	 * the data source.
	 * 
	 * @author Dan Schultz
	 */
	public class Commit
	{
		private var _dataSource:DataSource;
		private var _snapshots:Snapshots;
		
		private var _responders:Array = [];
		
		/**
		 * Constructor.
		 * 
		 * @param dataSource The data source to persist to.
		 * @param records The records to persist.
		 */
		public function Commit(dataSource:DataSource, records:Array)
		{
			super();
			_dataSource = dataSource;
			_snapshots = Snapshots.create(records);
		}
		
		/**
		 * Adds a callback responder to the commit to handle failures and successful commits.
		 * 
		 * @param responder The responder.
		 */
		public function addResponder(responder:ICommitResponder):void
		{
			_responders.push(responder);
		}
		
		private function handleOperationFault(event:FaultOperationEvent):void
		{
			for each (var responder:ICommitResponder in _responders) {
				responder.failed(event.summary, event.detail, event.code);
			}
		}
		
		private function handleOperationFinished(event:FinishedOperationEvent):void
		{
			if (event.successful) {
				for each (var responder:ICommitResponder in _responders) {
					responder.success();
				}
			}
		}
		
		/**
		 * Executes the persistence to the data source.
		 */
		public function persist():void
		{
			if (!operation.isExecuting) {
				operation.queue();
				operation.execute();
			}
		}
		
		private var _operation:Operation;
		/**
		 * The operation that handles the persistence to the data source.
		 */
		public function get operation():Operation
		{
			if (_operation == null) {
				_operation = new DataSourcePersistenceOperation(_dataSource, _snapshots);
				_operation.addEventListener(FaultOperationEvent.FAULT, handleOperationFault);
				_operation.addEventListener(FinishedOperationEvent.FINISHED, handleOperationFinished);
			}
			return _operation;
		}
	}
}

import flash.utils.Dictionary;

import mesh.mesh_internal;
import mesh.model.source.DataSource;
import mesh.model.source.IPersistenceResponder;
import mesh.model.source.Snapshot;
import mesh.model.source.Snapshots;
import mesh.operations.Operation;

use namespace mesh_internal;

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
		
		if (_snapshots.length > 0) {
			for each (var snapshot:Snapshot in _snapshots) {
				snapshot.record.changeState(snapshot.record.state.busy());
			}
			
			_saveCounter = 0;
			_persistedSnapshots = new Dictionary();
			
			_dataSource.createEach(this, _snapshots.create);
			_dataSource.updateEach(this, _snapshots.update);
			_dataSource.destroyEach(this, _snapshots.destroy);
		} else {
			finish(true);
		}
	}
}