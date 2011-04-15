package mesh.services
{
	import flash.utils.flash_proxy;
	
	import mesh.core.proxy.DataProxy;
	
	public dynamic class Request extends DataProxy
	{
		private var _block:Function;
		private var _handlers:Array = [];
		
		public function Request(block:Function)
		{
			super();
			_block = block;
			addHandler(new DefaultHandler());
		}
		
		public function addHandler(handler:Object):Request
		{
			if (!handler.hasOwnProperty("fault")) {
				handler.fault = function(fault:Object):void {};
			}
			
			if (!handler.hasOwnProperty("success")) {
				handler.success = function():void {};
			}
			
			_handlers.push(handler);
			return this;
		}
		
		public function execute(handler:Object = null):Request
		{
			if (handler != null) {
				addHandler(handler);
			}
			executeBlock(_block);
			return this;
		}
		
		protected function fault(fault:Object):void
		{
			for each (var handler:Object in _handlers) {
				handler.fault(fault);
			}
		}
		
		protected function result(data:Object):void
		{
			flash_proxy::object = data;
		}
		
		protected function success():void
		{
			for each (var handler:Object in _handlers) {
				handler.success();
			}
		}
		
		public function then(request:Request):Request
		{
			return new CompoundRequest([this, request]);
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