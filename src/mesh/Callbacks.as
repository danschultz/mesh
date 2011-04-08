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
		
		public function addCallback(method:String, block:Function):void
		{
			callbacks(method).add(new Callback(block));
		}
		
		public function callback(method:String, ...args):void
		{
			for each (var callback:Callback in callbacks(method)) {
				callback.execute(args);
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
	
	public function Callback(block:Function)
	{
		_block = block;
	}
	
	public function execute(args:Array):void
	{
		_block.apply(null, args);
	}
}