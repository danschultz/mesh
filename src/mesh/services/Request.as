package mesh.services
{
	import flash.utils.flash_proxy;
	
	import mesh.core.proxy.DataProxy;
	
	import mx.managers.CursorManager;
	
	use namespace flash_proxy;
	
	public dynamic class Request extends DataProxy
	{
		private var _block:Function;
		private var _handlers:Array = [];
		private var _isExecuting:Boolean;
		
		public function Request(block:Function = null)
		{
			super();
			_block = block != null ? block : function():void {
				success();
			};
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
		
		public function cancel():void
		{
			
		}
		
		public function execute(handler:Object = null):Request
		{
			if (!_isExecuting) {
				_isExecuting = true;
				
				showBusyCursor();
				if (handler != null) {
					addHandler(handler);
				}
				
				executeBlock(_block);
			}
			return this;
		}
		
		private var _useBusyCursor:Boolean;
		public function useBusyCursor():Request
		{
			_useBusyCursor = true;
			return this;
		}
		
		protected function fault(fault:Object):void
		{
			hideBusyCursor();
			for each (var handler:Object in _handlers) {
				handler.fault(fault);
			}
			_isExecuting = false;
		}
		
		protected function result(data:Object):void
		{
			object = data;
		}
		
		protected function success():void
		{
			hideBusyCursor();
			for each (var handler:Object in _handlers) {
				handler.success();
			}
			_isExecuting = false;
		}
		
		public function and(request:Request):Request
		{
			return new ParallelRequest([this, request]);
		}
		
		public function then(request:Request):Request
		{
			return new SequentialRequest([this, request]);
		}
		
		protected function blockArgs():Array
		{
			return [];
		}
		
		protected function executeBlock(block:Function):void
		{
			block.apply(null, blockArgs());
		}
		
		private function showBusyCursor():void
		{
			if (_useBusyCursor) {
				CursorManager.setBusyCursor();
			}
		}
		
		private function hideBusyCursor():void
		{
			if (_useBusyCursor) {
				CursorManager.removeBusyCursor();
			}
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