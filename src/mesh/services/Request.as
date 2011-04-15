package mesh.services
{
	import flash.utils.flash_proxy;
	
	import mesh.core.proxy.DataProxy;
	
	public dynamic class Request extends DataProxy
	{
		private var _block:Function;
		private var _handler:Object;
		
		public function Request(block:Function)
		{
			super();
			_block = block;
		}
		
		protected function fault(fault:Object):void
		{
			_handler.fault(fault);
		}
		
		protected function result(data:Object):void
		{
			flash_proxy::object = data;
		}
		
		protected function success():void
		{
			_handler.success();
		}
		
		public function then(request:Request):Request
		{
			return new CompoundRequest([this, request]);
		}
		
		public function execute(handler:Object = null):Request
		{
			_handler = handler != null ? handler : new DefaultHandler();
			
			if (!_handler.hasOwnProperty("fault")) {
				_handler.fault = function(fault:Object):void {};
			}
			
			if (!_handler.hasOwnProperty("success")) {
				_handler.success = function():void {};
			}
			
			executeBlock(_block);
			return this;
		}
		
		protected function blockArgs():Array
		{
			return [];
		}
		
		protected function executeBlock(block:Function):void
		{
			block.apply(null, blockArgs());
		}
	}
}



class DefaultHandler
{
	public function fault(fault:Object):void
	{
		
	}
	
	public function success():void
	{
		
	}
}