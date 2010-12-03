package mesh
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.utils.Proxy;
	
	import operations.EmptyOperation;
	import operations.Operation;

	/**
	 * An association proxy is a class that contains the references to the objects in
	 * a relationship, where the <em>owner</em> represents the object hosting the 
	 * association, and the <em>target</em> is the actual associated object.
	 * 
	 * @author Dan Schultz
	 */
	public class AssociationProxy extends Proxy implements IEventDispatcher
	{
		private var _dispatcher:EventDispatcher;
		
		/**
		 * Constructor.
		 * 
		 * @param owner The parent that owns the relationship.
		 * @param relationship The relationship being represented by the proxy.
		 */
		public function AssociationProxy(owner:Entity, relationship:Relationship)
		{
			super();
			_dispatcher = new EventDispatcher(this);
			_owner = owner;
			_relationship = relationship;
		}
		
		public function load():Operation
		{
			return new EmptyOperation();
		}
		
		protected function loaded():void
		{
			
		}
		
		public function revert():void
		{
			
		}
		
		/**
		 * 
		 *  
		 * @param validate
		 * @return 
		 */
		public function save(validate:Boolean = true):Operation
		{
			return new EmptyOperation();
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
		
		private var _isLoaded:Boolean;
		/**
		 * <code>true</code> if the association objects for this relationship have been
		 * loaded.
		 */
		public function get isLoaded():Boolean
		{
			return _isLoaded;
		}
		
		private var _relationship:Relationship;
		/**
		 * The relationship model that this association represents.
		 */
		protected function get relationship():Relationship
		{
			return _relationship;
		}
		
		private var _owner:Entity;
		/**
		 * The instance of the parent owning this association.
		 */
		protected function get owner():Entity
		{
			return _owner;
		}
		
		private var _target:Object;
		/**
		 * The instance of the the child for the association.
		 */
		public function get target():Object
		{
			return _target;
		}
		public function set target(value:Object):void
		{
			_target = value;
		}
	}
}