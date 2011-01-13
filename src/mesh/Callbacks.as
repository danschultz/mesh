package mesh
{
	import collections.ArrayList;
	import collections.HashMap;
	
	import flash.utils.Proxy;
	import flash.utils.flash_proxy;

	public class Callbacks extends Proxy
	{
		private var _callbacks:HashMap = new HashMap();
		
		public function Callbacks()
		{
			
		}
		
		public function addCallback(method:String, block:Function, args:Array):void
		{
			callbacks(method).add(new Callback(block, args));
		}
		
		public function callback(method:String):void
		{
			for each (var callback:Callback in callbacks(method)) {
				callback.execute();
			}
		}
		
		public function removeCallback(block:Function):void
		{
			for each (var list:ArrayList in _callbacks.values()) {
				list.removeAll(list.where(function(callback:Callback):Boolean
				{
					return callback.block == block;
				}));
			}
		}
		
		private function callbacks(method:String):ArrayList
		{
			if (!_callbacks.containsKey(method)) {
				_callbacks.put(method, new ArrayList());
			}
			return _callbacks.grab(method);
		}
		
		/**
		 * @inheritDoc
		 */
		override flash_proxy function callProperty(name:*, ...parameters):*
		{
			name = name.toString();
			
			if ((name.length > 6 && name.indexOf("before") == 0) || (name.length > 5 && name.indexOf("after") == 0)) {
				callback(name);
			}
		}
	}
}

class Callback
{
	private var _block:Function;
	private var _args:Array;
	
	public function Callback(block:Function, args:Array)
	{
		_block = block;
		_args = args;
	}
	
	public function execute():void
	{
		_block.apply(null, _args);
	}
	
	public function get block():Function
	{
		return _block;
	}
}