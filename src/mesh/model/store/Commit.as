package mesh.model.store
{
	import flash.events.EventDispatcher;
	
	import mesh.model.Record;
	import mesh.model.RecordSnapshot;
	import mesh.model.source.DataSource;
	import mesh.operations.FaultOperationEvent;
	import mesh.operations.FinishedOperationEvent;
	import mesh.operations.Operation;
	
	import mx.rpc.Fault;
	import mx.rpc.IResponder;
	
	public class Commit extends EventDispatcher
	{
		private var _responders:Array = [];
		
		//private var _snapshots:Snapshots;
		
		public function Commit(dataSource:DataSource, type:Class, records:Array)
		{
			super();
			//_snapshots = new Snapshots(dataSource, type, records);
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
				//_operation = _snapshots.createOperation();
				//_operation.addEventListener(FaultOperationEvent.FAULT, handleOperationFault);
				//_operation.addEventListener(FinishedOperationEvent.FINISHED, handleOperationFinished);
			}
			return _operation;
		}
	}
}

/*

import flash.errors.IllegalOperationError;

import mesh.mesh_internal;
import mesh.model.Record;
import mesh.model.RecordSnapshot;
import mesh.model.source.DataSource;
import mesh.operations.FinishedOperationEvent;
import mesh.operations.Operation;
import mesh.operations.SequentialOperation;

use namespace mesh_internal;

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
				chooseArray(record).push(record.snap());
			}
		}
	}
	
	private function data(snapshots:Array):Array
	{
		var result:Array = [];
		for each (var snapshot:RecordSnapshot in snapshots) {
			result.push(snapshot.data);
		}
		return result;
	}
	
	public function createOperation():Operation
	{
		var create:Operation = _dataSource.createEach(_type, data(_create));
		var update:Operation = _dataSource.updateEach(_type, data(_update));
		var destroy:Operation = _dataSource.destroyEach(_type, data(_destroy));
		
		var operation:Operation = new SequentialOperation([create, update, destroy]);
		operation.addEventListener(FinishedOperationEvent.FINISHED, handleRecordsSynced);
		return operation;
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
	
	private function handleRecordsSynced(event:FinishedOperationEvent):void
	{
		if (event.successful) {
			recordsCreated();
			recordsUpdated();
			recordsDestroyed();
		}
	}
	
	private function recordsCreated():void
	{
		for each (var snapshot:RecordSnapshot in _create) {
			var record:Record = Record( snapshot.origin );
			record.changeState(record.state.synced());
		}
	}
	
	private function recordsUpdated():void
	{
		for each (var snapshot:RecordSnapshot in _update) {
			var record:Record = Record( snapshot.origin );
			record.changeState(record.state.synced());
		}
	}
	
	private function recordsDestroyed():void
	{
		for each (var snapshot:RecordSnapshot in _destroy) {
			var record:Record = Record( snapshot.origin );
			record.changeState(record.state.synced());
		}
	}
}

*/