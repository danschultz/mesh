package mesh.model.store
{
	import mesh.core.object.merge;
	import mesh.model.source.SourceFault;

	/**
	 * The <code>AsyncRequest</code> class encapsulates a request to retrieve data from a data
	 * source. The request is initiated by invoking the <code>request()</code> method. To listen
	 * for a successful or failed request, responders may be added to the request.
	 * 
	 * @author Dan Schultz
	 */
	public class AsyncRequest
	{
		private var _responders:Array = [];
		private var _options:Object;
		
		/**
		 * Constructor.
		 * 
		 * @param data The data holder being loaded.
		 * @param store The data store that initiated the request.
		 * @param options An options hash to configure the request.
		 */
		public function AsyncRequest(store:Store, data:*, options:Object = null)
		{
			super();
			_store = store;
			_data = data;
			_options = merge({useBusyCursor:false, reload:false}, options);
		}
		
		/**
		 * Invoked by the data source when the request failed.
		 * 
		 * @param fault The reason for the failure.
		 */
		public function failed(fault:SourceFault):void
		{
			for each (var responder:Object in _responders) {
				if (responder.hasOwnProperty("failed")) {
					responder.failed(fault);
				}
			}
			finished();
		}
		
		/**
		 * Invoked by the data source when the result is received. The data must be an entity or list.
		 * 
		 * @param data An <code>Entity</code> or <code>IList</code>.
		 */
		public function result(data:*):void
		{
			for each (var responder:Object in _responders) {
				if (responder.hasOwnProperty("result")) {
					responder.result(data);
				}
			}
			finished();
		}
		
		/**
		 * Called after either a successful or failed attempt to request data. This method is used
		 * for cleaning up any data used during the request.
		 */
		protected function finished():void
		{
			_isBusy = false;
		}
		
		/**
		 * Adds a responder to the request. The responder can contain two functions:
		 * 
		 * <ul>
		 * <li><code>result(data:Object):void</code> - Called when the request is successful.
		 * <li><code>failed(fault:SourceFault):void</code> - Called when the request fails.
		 * </ul>
		 * 
		 * @param handler The handler object.
		 * @return This request.
		 */
		public function responder(handler:Object):AsyncRequest
		{
			_responders.push(handler);
			return this;
		}
		
		/**
		 * Initiates the request.
		 * 
		 * @return This instance.
		 */
		public function request():AsyncRequest
		{
			if (!isBusy) {
				_isBusy = true;
				
				if (!isLoaded || _options.reload) {
					executeRequest();
				}
			}
			return this;
		}
		
		/**
		 * A hook for sub-classes to override and initiate the loading of the request.
		 */
		protected function executeRequest():void
		{
			
		}
		
		private var _data:*;
		/**
		 * The data holder being loaded.
		 */
		public function get data():*
		{
			return _data;
		}
		
		private var _isBusy:Boolean;
		/**
		 * Indicates if the request is busy.
		 */
		public function get isBusy():Boolean
		{
			return _isBusy;
		}
		
		/**
		 * Indicates if the data has been loaded. Sub-classes usually override this property and 
		 * return the <code>isLoaded</code> property on the data.
		 */
		protected function get isLoaded():Boolean
		{
			return false;
		}
		
		private var _store:Store;
		/**
		 * The data store that created this request.
		 */
		public function get store():Store
		{
			return _store;
		}
	}
}