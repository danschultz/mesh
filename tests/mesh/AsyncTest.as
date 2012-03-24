package mesh
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	
	import org.flexunit.async.Async;

	public class AsyncTest extends EventDispatcher
	{
		public function AsyncTest(testCase:Object, timeout:int, handler:Function)
		{
			var wrapper:Function = function(event:Event, data:Object = null):void
			{
				handler();
			};
			addEventListener(Event.COMPLETE, Async.asyncHandler(testCase, wrapper, timeout));
		}
		
		public function complete():void
		{
			dispatchEvent( new Event(Event.COMPLETE) );
		}
	}
}