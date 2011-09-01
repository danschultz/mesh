package mesh.model.load
{
	import flash.events.Event;
	
	/**
	 * An event dispatched by an object that loads its content from a remote source.
	 * 
	 * @author Dan Schultz
	 */
	public class LoadEvent extends Event
	{
		/**
		 * Dispatched when an object starts loading its data.
		 */
		public static const LOADING:String = "loading";
		
		/**
		 * Constructor.
		 * 
		 * @param type The event type.
		 */
		public function LoadEvent(type:String, bubbles:Boolean = false, cancelable:Boolean = false)
		{
			super(type, bubbles, cancelable);
		}
		
		/**
		 * @inheritDoc
		 */
		override public function clone():Event
		{
			return new LoadEvent(type, bubbles, cancelable);
		}
	}
}