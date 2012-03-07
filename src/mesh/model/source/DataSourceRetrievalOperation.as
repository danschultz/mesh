package mesh.model.source
{
	import mesh.model.RecordState;
	import mesh.model.store.Data;
	import mesh.model.store.RecordCache;
	import mesh.operations.Operation;
	
	/**
	 * An operation that is responsible for executing a data source operation and handling
	 * its result.
	 * 
	 * @author Dan Schultz
	 */
	public class DataSourceRetrievalOperation extends Operation implements IRetrievalResponder
	{
		private var _records:RecordCache;
		private var _method:Function;
		private var _args:Array;
		
		/**
		 * Constructor.
		 * 
		 * @param records The store's records.
		 * @param operation The data source method to execute.
		 * @param args The args that will be passed to the data source.
		 */
		public function DataSourceRetrievalOperation(records:RecordCache, method:Function, args:Array)
		{
			super();
			
			_records = records;
			
			_method = method;
			_args = [this].concat(args);
		}
		
		/**
		 * @inheritDoc
		 */
		public function loaded(type:Class, data:Object, id:Object = null):void
		{
			if (id != null) {
				data.id = id;
			}
			_records.materialize(new Data(data, type), RecordState.loaded());
		}
		
		/**
		 * @inheritDoc
		 */
		public function failed(summary:String, detail:String = "", code:String = ""):void
		{
			fault(summary, detail, code);
		}
		
		/**
		 * @inheritDoc
		 */
		public function finished():void
		{
			finish(true);
		}
		
		/**
		 * @inheritDoc
		 */
		override protected function executeRequest():void
		{
			super.executeRequest();
			_method.apply(null, _args);
		}
	}
}