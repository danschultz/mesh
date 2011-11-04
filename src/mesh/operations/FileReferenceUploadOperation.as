package mesh.operations
{
	import flash.events.DataEvent;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.FileReference;
	import flash.net.URLRequest;
	
	import mesh.core.object.merge;

	/**
	 * An operation executes an upload on a <code>FileReference</code>. This operation defines
	 * a set of options that are passed to <code>FileReference.upload()</code>. These include:
	 * 
	 * <ul>
	 * <li><code>uploadDataFieldName:String</code> - (default = <code>"Filedata"</code>) See 
	 * 	<code>FileReference.upload()</code> for more information on this option.</li>
	 * <li><code>testUpload:Boolean</code> - (default = <code>false</code>) See 
	 * 	<code>FileReference.upload()</code> for more information on this option.</li>
	 * <li><code>finishOn:String</code> - (default = <code>Event.COMPLETE</code>) The event
	 * 	that signifies when this operation is finished. <code>FileReference</code> is capable
	 * 	of dispatching two complete events: <code>Event.COMPLETE</code> and 
	 * 	<code>DataEvent.UPLOAD_COMPLETE_DATA</code>. Set this option to <code>DataEvent.UPLOAD_COMPLETE_DATA</code>
	 * 	if you want the operation to not finish until data has been sent back from the upload
	 * 	server.</li>
	 * </ul>
	 * 
	 * @see http://help.adobe.com/en_US/FlashPlatform/reference/actionscript/3/flash/net/FileReference.html#upload() <code>FileReference.upload()</code>
	 * @author Dan Schultz
	 */
	public class FileReferenceUploadOperation extends NetworkOperation
	{
		private var _file:FileReference;
		private var _request:URLRequest;
		private var _options:Object;
		
		/**
		 * Constructor.
		 * 
		 * @param file The file to upload.
		 * @param request The request that contains the URL to upload to.
		 * @param options Options to pass to <code>FileReference.upload()</code>.
		 */
		public function FileReferenceUploadOperation(file:FileReference, request:URLRequest, options:Object = null)
		{
			super();
			_file = file;
			_file.addEventListener(ProgressEvent.PROGRESS, handleFileProgress);
			_file.addEventListener(IOErrorEvent.IO_ERROR, handleFileIOError);
			_file.addEventListener(SecurityErrorEvent.SECURITY_ERROR, handleFileSecurityError);
			_file.addEventListener(DataEvent.UPLOAD_COMPLETE_DATA, handleFileCompleteWithData);
			_file.addEventListener(Event.COMPLETE, handleFileComplete);
			
			_request = request;
			_options = merge({uploadDataFieldName:"Filedata", testUpload:false, finishOn:Event.COMPLETE}, options);
		}
		
		/**
		 * @inheritDoc
		 */
		override protected function cancelRequest():void
		{
			super.cancelRequest();
			_file.cancel();
		}
		
		private function canFinishWithEvent(event:Event):Boolean
		{
			return event.type == _options.finishOn;
		}
		
		/**
		 * @inheritDoc
		 */
		override protected function request():void
		{
			super.request();
			
			_file.cancel();
			_file.upload(_request, _options.uploadDataFieldName, _options.testUpload);
		}
		
		private function handleFileProgress(event:ProgressEvent):void
		{
			progressed(event.bytesLoaded);
		}
		
		private function handleFileIOError(event:IOErrorEvent):void
		{
			fault(event.text, event.text);
		}
		
		private function handleFileSecurityError(event:SecurityErrorEvent):void
		{
			fault(event.text, event.text);
		}
		
		private function handleFileCompleteWithData(event:DataEvent):void
		{
			result(event.data);
		}
		
		private function handleFileComplete(event:Event):void
		{
			if (canFinishWithEvent(event)) {
				finish(true);
			}
		}
		
		/**
		 * @inheritDoc
		 */
		override protected function get unitsTotal():Number
		{
			return _file.size;
		}
	}
}