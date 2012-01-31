package mesh.model.store
{
	import mesh.core.List;
	import mesh.mesh_internal;
	import mesh.operations.Operation;
	import mesh.operations.ResultOperationEvent;
	
	import mx.collections.IList;
	
	use namespace mesh_internal;
	
	public class ResultsList extends List
	{
		public function ResultsList(records:RecordCache, results:IList, loadOperation:Operation)
		{
			super();
			
			list = results;
			
			_loadOperation = loadOperation;
			_loadOperation.addEventListener(ResultOperationEvent.RESULT, function(event:ResultOperationEvent):void
			{
				for each (var data:Data in event.data) {
					records.materialize(data);
				}
				_isLoaded = true;
			});
		}
		
		/**
		 * @private
		 */
		override public function addItemAt(item:Object, index:int):void
		{
			// Disabled so clients can't add records directly to the result.
		}
		
		/**
		 * @copy mesh.model.Record#load()
		 */
		public function load():*
		{
			if (!isLoaded) {
				refresh();
			}
			return this;
		}
		
		/**
		 * @copy mesh.model.Record#refresh()
		 */
		public function refresh():*
		{
			loadOperation.queue();
			loadOperation.execute();
			return this;
		}
		
		/**
		 * @private
		 */
		override public function removeItemAt(index:int):Object
		{
			// Disabled so clients can't remove records directly from the result.
			return null;
		}
		
		/**
		 * @private
		 */
		override public function setItemAt(item:Object, index:int):Object
		{
			// Disabled so clients can't replace records directly in the result.
			return null;
		}
		
		private var _isLoaded:Boolean;
		/**
		 * @copy mesh.model.Record#isLoaded
		 */
		public function get isLoaded():Boolean
		{
			return _isLoaded;
		}
		
		private var _loadOperation:Operation;
		/**
		 * @copy mesh.model.Record#loadOperation
		 */
		public function get loadOperation():Operation
		{
			return _loadOperation;
		}
	}
}