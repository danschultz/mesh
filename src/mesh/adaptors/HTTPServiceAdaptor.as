package mesh.adaptors
{
	import flash.errors.IllegalOperationError;
	import flash.utils.getQualifiedClassName;
	
	import mesh.core.object.copy;
	
	import mx.rpc.http.HTTPMultiService;
	import mx.rpc.http.Operation;
	
	import operations.Operation;
	
	/**
	 * A service adaptor that uses a <code>HTTPMultiService</code> to perform persistence
	 * with a backend.
	 *  
	 * <p>
	 * This adaptor lazily creates <code>mx.rpc.http.Operation</code>s for its <code>HTTPMultiService</code>
	 * when sub-classes call <code>generateOperation()</code>. This method accepts an optional 
	 * third argument of type <code>Object</code>. Any values defined on this object will be set 
	 * on the new <code>mx.rpc.http.Operation</code>. 
	 * 
	 * <p>
	 * <strong>Example:</strong> Configuring the <code>mx.rpc.http.Operation</code>.
	 * <pre listing="3.0">
	 * return generateOperation("user_timeline", {user_id:options.user.id}, {resultFormat:"array", showBusyCursor:false});
	 * </pre>
	 * </p>
	 * </p>
	 * 
	 * <p>
	 * Any options that are defined on the <code>[ServiceAdaptor]</code> metadata or passed to 
	 * the constructor, will tried to be set on the adaptor's service.
	 * 
	 * <p>
	 * <strong>Example:</strong> Setting the busy cursor for the service.
	 * <pre listing="3.0">
	 * [ServiceAdaptor(showBusyCursor="true")]
	 * </pre>
	 * </p>
	 * </p>
	 * 
	 * @see http://help.adobe.com/en_US/FlashPlatform/reference/actionscript/3/mx/rpc/http/mxml/HTTPMultiService.html HTTPMultiService
	 * @author Dan Schultz
	 */
	public class HTTPServiceAdaptor extends RPCServiceAdaptor
	{
		private var _service:HTTPMultiService;
		
		/**
		 * Constructor.
		 * 
		 * @param entity The entity who owns this service adaptor.
		 * @param options An options hash to configure the adaptor.
		 */
		public function HTTPServiceAdaptor(entity:Class, options:Object)
		{
			_service = new HTTPMultiService();
			super(_service, entity, options);
		}
		
		/**
		 * The first argument is a string which represents the REST operation to call. The second
		 * argument is an optional object to pass to the operation. The third argument is an optional
		 * object who's values will be copied to the <code>mx.rpc.http.Operation</code> which is 
		 * generated from this function.
		 * 
		 * @inheritDoc
		 */
		override protected function generateOperation(...args):operations.Operation
		{
			if (_service.operations == null || _service.operations[args[0]] == null) {
				var operation:mx.rpc.http.Operation = createHTTPOperation(args[0], args[2]);
				_service.operationList = _service.operationList != null ? _service.operationList.concat(operation) : [operation];
			}
			
			if (args.length > 2) {
				args = args.slice(0, 2);
			}
			
			return super.generateOperation.apply(null, args);
		}
		
		/**
		 * A helper method that can be used by sub-classes to generate new HTTP operations. This
		 * method takes in an options hash, which will be copied to the generated operation.
		 * 
		 * @param name The name of the operation.
		 * @param options Any options to set on the operation.
		 * @return A new operation.
		 */
		private function createHTTPOperation(name:String, options:Object = null):mx.rpc.http.Operation
		{
			var operation:mx.rpc.http.Operation = new mx.rpc.http.Operation();
			operation.name = name;
			
			if (options != null) {
				copy(options, operation);
			}
			
			return operation;
		}
	}
}