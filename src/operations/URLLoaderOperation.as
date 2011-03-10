package operations
{
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	
	/**
	 * An asynchronous operation that wraps Flash's <code>URLLoader</code> to perform
	 * a network operation.
	 * 
	 * @see http://help.adobe.com/en_US/FlashPlatform/reference/actionscript/3/flash/net/URLLoader.html URLLoader
	 * @author Dan Schultz
	 */
	public class URLLoaderOperation extends NetworkOperation
	{
		private var _request:URLRequest;
		private var _loader:URLLoader;
		
		/**
		 * Constructor.
		 * 
		 * @param request The request to execute.
		 * @param dataFormat The data format of the result. Use one of the constants defined on
		 * 	<code>URLLoaderDataFormat</code>.
		 * @see http://help.adobe.com/en_US/FlashPlatform/reference/actionscript/3/flash/net/URLLoaderDataFormat.html URLLoaderDataFormat
		 */
		public function URLLoaderOperation(request:URLRequest, dataFormat:String = URLLoaderDataFormat.TEXT)
		{
			super();
			
			_request = request;
			_loader = new URLLoader();
			_loader.dataFormat = dataFormat;
		}
		
		/**
		 * @inheritDoc
		 */
		override protected function request():void
		{
			super.request();
			
			_loader.addEventListener(IOErrorEvent.IO_ERROR, handleLoaderIOError);
			_loader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, handleLoaderSecurityError);
			_loader.addEventListener(Event.COMPLETE, handleLoaderComplete);
			_loader.load(_request);
		}
		
		/**
		 * @inheritDoc
		 */
		override protected function cancelRequest():void
		{
			super.cancelRequest();
			
			try {
				_loader.close();
			} catch (e:Error) {
				
			}
		}
		
		private function handleLoaderIOError(event:IOErrorEvent):void
		{
			fault(event.text, event.text);
		}
		
		private function handleLoaderSecurityError(event:SecurityErrorEvent):void
		{
			fault(event.text, event.text);
		}
		
		private function handleLoaderComplete(event:Event):void
		{
			result(_loader.data);
		}
	}
}