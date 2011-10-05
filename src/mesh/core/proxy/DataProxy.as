package mesh.core.proxy
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.utils.Proxy;
	import flash.utils.flash_proxy;
	
	import mx.events.PropertyChangeEvent;
	
	use namespace flash_proxy;
	
	/**
	 * The <code>DataProxy</code> class represents a base <code>Proxy</code> implementation. A
	 * proxy wraps an arbitrary object and forwards function and property calls to it. In 
	 * addition, this proxy will forward any property change events dispatched by its wrapped
	 * object. This allows for UI controls to bind directly to the proxy class.
	 * 
	 * @author Dan Schultz
	 */
	public dynamic class DataProxy extends Proxy implements IEventDispatcher
	{
		private var _dispatcher:EventDispatcher;
		
		/**
		 * Constructor.
		 */
		public function DataProxy(obj:Object = null)
		{
			super();
			_dispatcher = new EventDispatcher(this);
			object = obj;
		}
		
		/**
		 * @inheritDoc
		 */
		override flash_proxy function callProperty(name:*, ...parameters):*
		{
			if (object != null) {
				return object[name].apply(null, parameters);
			}
			return undefined;
		}
		
		/**
		 * @inheritDoc
		 */
		override flash_proxy function getProperty(name:*):*
		{
			if (object != null) {
				return object[name];
			}
			return undefined;
		}
		
		private function handlePropertyChange(event:PropertyChangeEvent):void
		{
			dispatchEvent(event);
		}
		
		/**
		 * @inheritDoc
		 */
		override flash_proxy function hasProperty(name:*):Boolean
		{
			try {
				return getProperty(name) !== undefined;
			} catch (e:Error) {
				
			}
			return false;
		}
		
		/**
		 * @inheritDoc
		 */
		override flash_proxy function setProperty(name:*, value:*):void
		{
			if (object != null) {
				object[name] = value;
			}
		}
		
		private var _object:*;
		[Bindable]
		/**
		 * The object being proxied.
		 */
		flash_proxy function get object():*
		{
			return _object;
		}
		flash_proxy function set object(value:*):void
		{
			if (_object is IEventDispatcher) {
				(_object as IEventDispatcher).removeEventListener(PropertyChangeEvent.PROPERTY_CHANGE, handlePropertyChange);
			}
			
			_object = value;
			
			if (_object is IEventDispatcher) {
				(_object as IEventDispatcher).addEventListener(PropertyChangeEvent.PROPERTY_CHANGE, handlePropertyChange);
			}
		}
		
		/**
		 * @inheritDoc
		 */
		public function addEventListener(type:String, listener:Function, useCapture:Boolean = false, priority:int = 0, useWeakReference:Boolean = false):void
		{
			_dispatcher.addEventListener(type, listener, useCapture, priority, useWeakReference);
		}
		
		/**
		 * @inheritDoc
		 */
		public function dispatchEvent(event:Event):Boolean
		{
			return _dispatcher.dispatchEvent(event);
		}
		
		/**
		 * @inheritDoc
		 */
		public function hasEventListener(type:String):Boolean
		{
			return _dispatcher.hasEventListener(type);
		}
		
		/**
		 * @inheritDoc
		 */
		public function removeEventListener(type:String, listener:Function, useCapture:Boolean = false):void
		{
			_dispatcher.removeEventListener(type, listener, useCapture);
		}
		
		/**
		 * @inheritDoc
		 */
		public function willTrigger(type:String):Boolean
		{
			return _dispatcher.willTrigger(type);
		}
	}
}