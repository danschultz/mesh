package mesh
{
	import collections.ArraySequence;
	import collections.HashMap;

	public class Callbacks
	{
		private var _callbacks:HashMap = new HashMap();
		
		public function Callbacks()
		{
			
		}
		
		public function addCallback(method:String, block:Function):void
		{
			callbacks(method).add( new Callback(method, block) );
		}
		
		public function callback(method:String, ...args):void
		{
			for each (var callback:Callback in callbacks(method)) {
				callback.execute(args);
			}
		}
		
		private function callbacks(method:String):ArraySequence
		{
			if (!_callbacks.containsKey(method)) {
				_callbacks.put(method, new ArraySequence());
			}
			return _callbacks.grab(method);
		}
		
		public function removeCallback(method:String, block:Function):void
		{
			var callbacks:ArraySequence = callbacks(method)
			for each (var callback:Callback in callbacks) {
				if (callback.block == block) {
					callbacks.remove(callback);
					break;
				}
			}
		}
	}
}

class Callback
{
	private var _block:Function;
	private var _method:String;
	
	public function Callback(method:String, block:Function)
	{
		_block = block;
	}
	
	public function execute(args:Array):void
	{
		_block.apply(null, args);
	}
	
	public function get method():String
	{
		return _method;
	}
	
	public function get block():Function
	{
		return _block;
	}
}