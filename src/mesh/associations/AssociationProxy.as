package mesh.associations
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.utils.Proxy;
	import flash.utils.flash_proxy;
	import flash.utils.setTimeout;
	
	import mesh.Entity;
	import mesh.EntityDescription;
	
	import operations.EmptyOperation;
	import operations.FinishedOperationEvent;
	import operations.Operation;
	import operations.ResultOperationEvent;

	/**
	 * An association proxy is a class that contains the references to the objects in
	 * a relationship, where the <em>owner</em> represents the object hosting the 
	 * association, and the <em>target</em> is the actual associated object.
	 * 
	 * @author Dan Schultz
	 */
	public dynamic class AssociationProxy extends Proxy implements IEventDispatcher
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
		
		/**
		 * Executes an operation that will load the target for this association.
		 * 
		 * @return An executing operation.
		 */
		final public function load():Operation
		{
			var operation:Operation = isLoaded ? new EmptyOperation() : generateLoadOperation();
			operation.addEventListener(ResultOperationEvent.RESULT, function(event:ResultOperationEvent):void
			{
				target = event.data;
			});
			operation.addEventListener(FinishedOperationEvent.FINISHED, function(event:FinishedOperationEvent):void
			{
				if (event.successful) {
					loaded();
				}
			});
			setTimeout(operation.execute, 50);
			return operation;
		}
		
		/**
		 * Generates an unexecuted operation that will be used to load the target of the
		 * association.
		 * 
		 * @return An unexecuted operation.
		 */
		protected function generateLoadOperation():Operation
		{
			return Entity.adaptorFor(relationship.target).belongingTo(owner, relationship);
		}
		
		public function loaded():void
		{
			_isLoaded = true;
			
			if (target.hasOwnProperty("loaded")) {
				target.loaded();
			}
		}
		
		/**
		 * Changes the state of the target for this association back to what it was at the
		 * last save.
		 */
		public function revert():void
		{
			
		}
		
		/**
		 * Saves the target association.
		 *  
		 * @param validate
		 * @return 
		 */
		public function save(validate:Boolean = true):Operation
		{
			return new EmptyOperation();
		}
		
		/**
		 * @copy Entity#isDirty
		 */
		public function get isDirty():Boolean
		{
			return target != null && target.isDirty;
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
		
		/**
		 * @inheritDoc
		 */
		override flash_proxy function callProperty(name:*, ...parameters):*
		{
			if (target != null) {
				return target[name].apply(null, parameters);
			}
			return undefined;
		}
		
		/**
		 * @inheritDoc
		 */
		override flash_proxy function getProperty(name:*):*
		{
			if (target != null) {
				return target[name];
			}
			return undefined;
		}
		
		/**
		 * @inheritDoc
		 */
		override flash_proxy function hasProperty(name:*):Boolean
		{
			return flash_proxy::getProperty(name);
		}
		
		/**
		 * @inheritDoc
		 */
		override flash_proxy function setProperty(name:*, value:*):void
		{
			if (target != null) {
				target[name] = value;
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