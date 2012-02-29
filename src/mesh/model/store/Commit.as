package mesh.model.store
{
	import flash.events.EventDispatcher;
	
	import mesh.model.Record;
	import mesh.model.source.DataSource;
	import mesh.operations.FaultOperationEvent;
	import mesh.operations.FinishedOperationEvent;
	import mesh.operations.Operation;
	
	import mx.rpc.Fault;
	import mx.rpc.IResponder;
	
	public class Commit extends EventDispatcher
	{
		private var _responders:Array = [];
		
		private var _snapshots:Snapshots;
		
		public function Commit(dataSource:DataSource, type:Class, records:Array)
		{
			super();
			_snapshots = new Snapshots(dataSource, type, records);
		}
		
		/**
		 * Adds a responder object to this commit. Responders handle the result and fault callbacks
		 * from a persistence call.
		 * 
		 * @param responder The responder to add.
		 * @return This instance.
		 */
		public function addResponder(responder:IResponder):Commit
		{
			_responders.push(responder);
			return this;
		}
		
		private function handleOperationFault(event:FaultOperationEvent):void
		{
			for each (var responder:IResponder in _responders) {
				responder.fault(new Fault(event.code, event.summary, event.detail));
			}
		}
		
		private function handleOperationFinished(event:FinishedOperationEvent):void
		{
			if (event.successful) {
				for each (var responder:IResponder in _responders) {
					responder.result(this);
				}
			}
		}
		
		/**
		 * Persists the changes of the record to its data source.
		 * 
		 * @return This instance.
		 */
		public function persist():Commit
		{
			if (!operation.isExecuting) {
				operation.queue();
				operation.execute();
			}
			return this;
		}
		
		private var _operation:Operation;
		public function get operation():Operation
		{
			if (_operation == null) {
				_operation = _snapshots.createOperation();
				_operation.addEventListener(FaultOperationEvent.FAULT, handleOperationFault);
				_operation.addEventListener(FinishedOperationEvent.FINISHED, handleOperationFinished);
			}
			return _operation;
		}
	}
}

import flash.errors.IllegalOperationError;

import mesh.model.Record;
import mesh.model.source.DataSource;
import mesh.operations.Operation;
import mesh.operations.SequentialOperation;

class Snapshots
{
	private var _dataSource:DataSource;
	private var _type:Class;
	
	private var _create:Array = [];
	private var _update:Array = [];
	private var _destroy:Array = [];
	
	public function Snapshots(dataSource:DataSource, type:Class, records:Array)
	{
		_dataSource = dataSource;
		_type = type;
		serialize(records);
	}
	
	private function serialize(records:Array):void
	{
		for each (var record:Record in records) {
			if (!record.state.isSynced) {
				chooseArray(record).push(record.snap().data);
			}
		}
	}
	
	public function createOperation():Operation
	{
		return new SequentialOperation(
			[
				_dataSource.createEach(_type, _create),
				_dataSource.updateEach(_type, _update),
				_dataSource.destroyEach(_type, _destroy)
			]
		);
	}
	
	private function chooseArray(record:Record):Array
	{
		if (record.state.willBeCreated) {
			return _create;
		}
		
		if (record.state.willBeUpdated) {
			return _update;
		}
		
		if (record.state.willBeDestroyed) {
			return _destroy;
		}
		
		throw new IllegalOperationError("Cannot commit record");
	}
}