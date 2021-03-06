package mesh.model.source
{
	import flash.errors.IllegalOperationError;
	import flash.utils.Dictionary;
	
	import mesh.core.reflection.Type;
	import mesh.core.reflection.reflect;
	import mesh.model.Record;
	
	/**
	 * A data source that maps a type of record to its source.
	 * 
	 * <p>
	 * This source respects the inhertence of entities. For instance, say you have 
	 * record <code>A</code>, and record <code>B</code> that extends from <code>A</code>. 
	 * If you map <code>A</code> to an source, then <code>B</code> will use the same 
	 * source as <code>A</code>.
	 * </p>
	 * 
	 * @author Dan Schultz
	 */
	public class MultiDataSource extends DataSource
	{
		private var _mapping:Dictionary = new Dictionary();
		private var _dataSources:Array = [];
		
		/**
		 * Constructor.
		 */
		public function MultiDataSource()
		{
			super();
		}
		
		/**
		 * Maps a record type to a data source. This source respects the inhertence 
		 * of entities. For instance, say you have record <code>A</code>, and record 
		 * <code>B</code> that extends from <code>A</code>. If you map <code>A</code> to
		 * an source, then <code>B</code> will use the same source as <code>A</code>.
		 * 
		 * @param record The record type to map.
		 * @param dataSource The data source to use for the record.
		 */
		public function map(record:Class, dataSource:DataSource):void
		{
			if (_mapping[record] == null) {
				_mapping[record] = dataSource;
				_dataSources.push(dataSource);
			}
		}
		
		/**
		 * @inheritDoc
		 */
		override public function belongingTo(responder:IRetrievalResponder, record:Record, type:Class):void
		{
			invoke("belongingTo", responder, record, type);
		}
		
		/**
		 * @inheritDoc
		 */
		override public function create(responder:IPersistenceResponder, snapshot:Snapshot):void
		{
			invoke("create", responder, snapshot);
		}
		
		/**
		 * @inheritDoc
		 */
		override public function createEach(responder:IPersistenceResponder, snapshots:Array):void
		{
			groupAndInvoke("createEach", responder, snapshots);
		}
		
		/**
		 * @inheritDoc
		 */
		override public function destroy(responder:IPersistenceResponder, snapshot:Snapshot):void
		{
			invoke("destroy", responder, snapshot);
		}
		
		/**
		 * @inheritDoc
		 */
		override public function destroyEach(responder:IPersistenceResponder, snapshots:Array):void
		{
			groupAndInvoke("destroyEach", responder, snapshots);
		}
		
		/**
		 * @inheritDoc
		 */
		override public function retrieve(responder:IRetrievalResponder, record:Record):void
		{
			invoke("retrieve", responder, record);
		}
		
		/**
		 * @inheritDoc
		 */
		override public function retrieveAll(responder:IRetrievalResponder, type:Class):void
		{
			invoke("retrieveAll", responder, type);
		}
		
		/**
		 * @inheritDoc
		 */
		override public function search(responder:IRetrievalResponder, type:Class, params:Object):void
		{
			invoke("search", responder, type, params);
		}
		
		/**
		 * @inheritDoc
		 */
		override public function update(responder:IPersistenceResponder, snapshot:Snapshot):void
		{
			invoke("update", responder, snapshot);
		}
		
		/**
		 * @inheritDoc
		 */
		override public function updateEach(responder:IPersistenceResponder, snapshots:Array):void
		{
			groupAndInvoke("updateEach", responder, snapshots);
		}
		
		/**
		 * Returns the data source that is mapped to the given record. If no source is
		 * mapped, then <code>null</code> is returned.
		 * 
		 * @param record The record type to get the source for.
		 * @return The source mapped to the given record.
		 */
		protected function sourceFor(record:Object):DataSource
		{
			if (record is Array) {
				record = record[0];
			}
			
			if (record is Snapshot) {
				record = (record as Snapshot).record;
			}
			
			if (record is Record) {
				record = (record as Record).reflect.clazz;
			}
			
			var source:DataSource = _mapping[record];
			if (source != null) {
				return source;
			}
			
			var parent:Class = reflect(record).parent.clazz;
			if (parent != Record) {
				return sourceFor(parent);
			}
			
			return null;
		}
		
		private function invoke(method:String, ...args):*
		{
			var source:DataSource = sourceFor(args[1]);
			throwIfSourceIsNull(source, reflect(args[1]));
			return source[method].apply(null, args);
		}
		
		private function group(snapshots:Array):Array
		{
			var cache:Dictionary = new Dictionary();
			var groups:Array = [];
			for each (var snapshot:Snapshot in snapshots) {
				var type:Class = snapshot.record.reflect.clazz;
				if (cache[type] == null) {
					cache[type] = [];
					groups.push(cache[type]);
				}
				cache[type].push(snapshot);
			}
			return groups;
		}
		
		private function groupAndInvoke(method:String, ...args):*
		{
			for each (var g:Array in group(args[1])) {
				invoke(method, args[0], g);
			}
		}
		
		private function throwIfSourceIsNull(dataSource:DataSource, recordType:Type):void
		{
			if (dataSource == null) {
				throwUnmappedError(recordType);
			}
		}
		
		private function throwUnmappedError(recordType:Type):void
		{
			throw new IllegalOperationError("Source undefined for '" + recordType.name + "'");
		}
	}
}