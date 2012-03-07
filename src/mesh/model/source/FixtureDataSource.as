package mesh.model.source
{
	import collections.HashMap;
	
	import flash.utils.setTimeout;
	
	import mesh.core.object.merge;
	import mesh.model.ID;
	import mesh.model.Record;
	
	import mx.utils.ObjectUtil;

	/**
	 * A data source that is used for static or test data.
	 * 
	 * @author Dan Schultz
	 */
	public class FixtureDataSource extends DataSource
	{
		private var _fixtures:HashMap = new HashMap();
		
		private var _type:Class;
		private var _options:Object;
		
		private var _idCounter:int;
		
		/**
		 * Constructor.
		 * 
		 * @param type The type of records this data source is for.
		 * @param options A hash of options.
		 */
		public function FixtureDataSource(type:Class, options:Object = null)
		{
			super();
			_type = type;
			_options = merge({idField:"id", latency:0}, options);
		}
		
		/**
		 * Adds a fixture to this data source.
		 * 
		 * @param data The data to add.
		 */
		public function add(data:Object):void
		{
			_fixtures.put(data[_options.idField], data);
		}
		
		private function invoke(block:Function):void
		{
			if (_options.latency > 0) setTimeout(block, _options.latency);
			else block()
		}
		
		/**
		 * @inheritDoc
		 */
		override public function create(responder:IPersistenceResponder, snapshot:Snapshot):void
		{
			if (snapshot.record.reflect.clazz == _type) {
				var data:Object = ObjectUtil.copy(snapshot.data);
				var id:* = data[_options.idField];
				if (_fixtures.containsKey(id)) {
					responder.failed("Fixture type '" + snapshot.record.reflect + "' with ID=" + id + " already exists.");
					return;
				}
				
				data[_options.idField] = ++_idCounter;
				add(data);
				responder.saved(snapshot, data[_options.idField]);
			}
		}
		
		/**
		 * @inheritDoc
		 */
		override public function destroy(responder:IPersistenceResponder, snapshot:Snapshot):void
		{
			if (snapshot.record.reflect.clazz == _type) {
				var id:* = snapshot.data[_options.idField];
				if (_fixtures.remove(id) == null) {
					responder.failed("Fixture type '" + snapshot.record.reflect + "' does not exist with ID=" + id + ".");
					return;
				}
				responder.saved(snapshot);
			}
		}
		
		/**
		 * @inheritDoc
		 */
		override public function retrieve(responder:IRetrievalResponder, record:Record):void
		{
			if (record.reflect.clazz != _type) {
				throw new ArgumentError("Invalid record type.");
			}
			responder.loaded(record.reflect.clazz, _fixtures.grab(record.id));
			responder.finished();
		}
		
		/**
		 * @inheritDoc
		 */
		override public function retrieveAll(responder:IRetrievalResponder, type:Class):void
		{
			if (type != _type) {
				throw new ArgumentError("Invalid record type.");
			}
			
			for each (var fixture:Object in _fixtures.values()) {
				responder.loaded(type, fixture);
			}
			responder.finished();
		}
		
		/**
		 * @inheritDoc
		 */
		override public function search(responder:IRetrievalResponder, type:Class, params:Object):void
		{
			if (type != _type) {
				throw new ArgumentError("Invalid record type.");
			}
			
			retrieveAll(responder, type);
		}
		
		/**
		 * @inheritDoc
		 */
		override public function update(responder:IPersistenceResponder, snapshot:Snapshot):void
		{
			if (snapshot.record.reflect.clazz == _type) {
				if (!ID.isPopulated(snapshot.data, _options.idField)) {
					responder.failed("Cannot update fixture type '" + snapshot.record.reflect + "' without ID.");
					return;
				}
				add(ObjectUtil.copy(snapshot.data));
				responder.saved(snapshot);
			}
		}
	}
}

import flash.utils.setTimeout;

import mesh.operations.MethodOperation;

class TimedOperation extends MethodOperation
{
	private var _timeout:Number;
	
	public function TimedOperation(timeout:Number, block:Function)
	{
		super(block);
		_timeout = timeout;
	}
	
	override protected function executeRequest():void
	{
		if (_timeout > 0) setTimeout(super.executeRequest, _timeout);
		else super.executeRequest();
	}
}