package mesh.model.source
{
	import flash.errors.IllegalOperationError;
	import flash.utils.Dictionary;
	
	import mesh.core.reflection.Type;
	import mesh.core.reflection.reflect;
	import mesh.model.Record;
	import mesh.operations.Operation;
	
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
			_mapping[record] = dataSource;
		}
		
		/**
		 * @inheritDoc
		 */
		override public function retrieve(recordType:Class, id:Object):Operation
		{
			return invoke("retrieve", recordType, id);
		}
		
		/**
		 * @inheritDoc
		 */
		override public function search(recordType:Class, params:Object):Operation
		{
			return invoke("search", recordType, params);
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
			record = record is Record ? (record as Record).reflect.clazz : record;
			
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
			var source:DataSource = sourceFor(args[0]);
			throwIfSourceIsNull(source, reflect(args[0]));
			return source[method].apply(null, args);
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