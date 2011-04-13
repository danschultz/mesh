package mesh.services
{
	import flash.utils.flash_proxy;
	
	import mesh.adaptors.ServiceAdaptor;
	import mesh.core.proxy.DataProxy;
	import mesh.operations.FaultOperationEvent;
	import mesh.operations.FinishedOperationEvent;
	import mesh.operations.Operation;
	import mesh.operations.ResultOperationEvent;
	
	import mx.rpc.Fault;
	
	public class Request extends DataProxy
	{
		private var _block:Function;
		private var _handler:Object;
		
		public function Request(block:Function)
		{
			super();
			_block = block;
		}
		
		public function fault(fault:Object):void
		{
			_handler.fault(fault);
		}
		
		public function result(data:Object):void
		{
			flash_proxy::object = _handler.parse(data);
		}
		
		public function finished():void
		{
			_handler.success();
		}
		
		public function then(request:Request):Request
		{
			return new CompoundRequest([this, request]);
		}
		
		public function execute(handler:Object = null):void
		{
			_handler = handler != null ? handler : new DefaultHandler();
			executeBlock(_block);
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

import mx.rpc.Fault;

class DefaultHandler
{
	public function fault(fault:Fault):void
	{
		
	}
	
	public function parse(data:Object):Object
	{
		return data;
	}
	
	public function success():void
	{
		
	}
}