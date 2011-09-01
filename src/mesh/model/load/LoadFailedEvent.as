package mesh.model.load
{
	import flash.events.Event;
	
	import mesh.model.source.SourceFault;

	/**
	 * An event dispatched by an object when it fails to load its content from a remote source.
	 * 
	 * @author Dan Schultz
	 */
	public class LoadFailedEvent extends LoadEvent
	{
		/**
		 * Dispatched when an object successfully loads its content.
		 */
		public static const FAILED:String = "failed";
		
		/**
		 * Constructor.
		 * 
		 * @param type The type of event.
		 * @param fault The reason for the failure.
		 */
		public function LoadFailedEvent(type:String, fault:SourceFault, bubbles:Boolean = false, cancelable:Boolean = false)
		{
			super(type, bubbles, cancelable);
			_fault = fault;
		}
		
		/**
		 * @inheritDoc
		 */
		override public function clone():Event
		{
			return new LoadFailedEvent(type, fault, bubbles, cancelable);
		}
		
		private var _fault:SourceFault;
		/**
		 * The reason for the failure.
		 */
		public function get fault():SourceFault
		{
			return _fault;
		}
	}
}