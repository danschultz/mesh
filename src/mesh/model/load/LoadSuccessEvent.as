package mesh.model.load
{
	import flash.events.Event;

	/**
	 * An event dispatched by an object when it loads its content from a remote source.
	 * 
	 * @author Dan Schultz
	 */
	public class LoadSuccessEvent extends LoadEvent
	{
		/**
		 * Dispatched when an object successfully loads its content.
		 */
		public static const SUCCESS:String = "success";
		
		/**
		 * Constructor.
		 * 
		 * @param type The type of event.
		 */
		public function LoadSuccessEvent(type:String, bubbles:Boolean = false, cancelable:Boolean = false)
		{
			super(type, bubbles, cancelable);
		}
		
		/**
		 * @inheritDoc
		 */
		override public function clone():Event
		{
			return new LoadSuccessEvent(type, bubbles, cancelable);
		}
	}
}