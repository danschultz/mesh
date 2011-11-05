package mesh.model.source
{
	import mesh.core.object.copy;
	import mesh.operations.ServiceOperation;
	
	import mx.core.mx_internal;
	import mx.rpc.http.HTTPMultiService;
	import mx.rpc.http.Operation;
	
	use namespace mx_internal;
	
	public class HTTPSource extends RPCSource
	{
		private var _service:HTTPSourceService;
		
		/**
		 * Constructor.
		 */
		public function HTTPSource()
		{
			_service = new HTTPSourceService();
			super(_service);
			configure(_service);
		}
		
		/**
		 * Called during creation to allow sub-classes to configure the service.
		 * 
		 * @param service The source's service.
		 */
		protected function configure(service:HTTPMultiService):void
		{
			
		}
		
		/**
		 * The first argument is a unique name for the operation to call. The second argument is a 
		 * required options hash to pass to the operation, which must include the URL to call. These
		 * options will be copied onto the instance of <code>mx.rpc.http.Operation</code> which is
		 * the object that actually executes the call. The third argument is the parameters hash that's
		 * passed to the HTTP service.
		 * 
		 * @inheritDoc
		 */
		override protected function createOperation(name:String, ...args):ServiceOperation
		{
			if (_service.operations == null || _service.operations[name] == null) {
				_service.addOperation(createHTTPOperation(name, args[0]));
			}
			
			if (args.length > 1) {
				args = args.slice(1);
			}
			
			return super.createOperation.apply(null, [name].concat(args));
		}
		
		private function createHTTPOperation(name:String, options:Object = null):Operation
		{
			var operation:Operation = new Operation();
			operation.name = name;
			operation.setService(_service);
			
			if (options != null) {
				copy(options, operation);
			}
			
			return operation;
		}
	}
}

import mx.core.mx_internal;
import mx.rpc.http.HTTPMultiService;
import mx.rpc.http.Operation;

use namespace mx_internal;

class HTTPSourceService extends HTTPMultiService
{
	public function HTTPSourceService()
	{
		super();
	}
	
	public function addOperation(operation:Operation):void
	{
		_operations[operation.name] = operation;
	}
}