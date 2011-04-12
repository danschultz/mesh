package mesh.associations
{
	import flash.errors.IllegalOperationError;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.utils.Proxy;
	import flash.utils.flash_proxy;
	import flash.utils.setTimeout;
	
	import mesh.Callbacks;
	import mesh.Entity;
	import mesh.Mesh;
	import mesh.operations.EmptyOperation;
	import mesh.operations.FinishedOperationEvent;
	import mesh.operations.Operation;
	import mesh.operations.OperationEvent;
	import mesh.operations.ResultOperationEvent;
	
	import mx.events.PropertyChangeEvent;

	/**
	 * An association class is a proxy object that contains the references to the objects in
	 * a relationship, where the <em>owner</em> represents the object hosting the association, 
	 * and the <em>target</em> is the actual associated object.
	 * 
	 * @author Dan Schultz
	 */
	public dynamic class Association extends Proxy implements IEventDispatcher
	{
		private var _dispatcher:EventDispatcher;
		private var _callbacks:Callbacks = new Callbacks();
		
		/**
		 * Constructor.
		 * 
		 * @param owner The parent that owns the relationship.
		 * @param relationship The relationship being represented by the proxy.
		 */
		public function Association(owner:Entity, definition:AssociationDefinition)
		{
			super();
			
			_dispatcher = new EventDispatcher(this);
			_owner = owner;
			_definition = definition;
			
			beforeLoad(loading);
			afterLoad(loaded);
			
			beforeAdd(populateForeignKey);
			beforeAdd(reviveEntity);
			
			beforeRemove(markEntityForRemoval);
		}
		
		private function addCallback(method:String, block:Function):void
		{
			_callbacks.addCallback(method, block);
		}
		
		protected function beforeAdd(block:Function):void
		{
			addCallback("beforeAdd", block);
		}
		
		protected function beforeRemove(block:Function):void
		{
			addCallback("beforeRemove", block);
		}
		
		protected function beforeLoad(block:Function):void
		{
			addCallback("beforeLoad", block);
		}
		
		protected function afterAdd(block:Function):void
		{
			addCallback("afterAdd", block);
		}
		
		protected function afterRemove(block:Function):void
		{
			addCallback("afterRemove", block);
		}
		
		protected function afterLoad(block:Function):void
		{
			addCallback("afterLoad", block);
		}
		
		protected function callback(method:String, entity:Entity = null):void
		{
			if (entity != null) {
				_callbacks.callback(method, entity);
			} else {
				_callbacks.callback(method);
			}
		}
		
		protected function callbackIfNotNull(method:String, entity:Entity):void
		{
			if (entity != null) {
				callback(method, entity);
			}
		}
		
		/**
		 * Executes an operation that will load the target for this association.
		 * 
		 * @return An executing operation.
		 */
		final public function load():Operation
		{
			var operation:Operation = (isLoaded || isLoading) ? new EmptyOperation() : createLoad();
			setTimeout(operation.execute, Mesh.DELAY);
			return operation;
		}
		
		private function createLoad():Operation
		{
			var operation:Operation = definition.hasLoad ? definition.load() : createLoadOperation();
			operation.addEventListener(OperationEvent.BEFORE_EXECUTE, function(event:OperationEvent):void
			{
				callback("beforeLoad");
			});
			operation.addEventListener(ResultOperationEvent.RESULT, function(event:ResultOperationEvent):void
			{
				target = event.data;
			});
			operation.addEventListener(FinishedOperationEvent.FINISHED, function(event:FinishedOperationEvent):void
			{
				callback("afterLoad");
			});
			return operation;
		}
		
		protected function createLoadOperation():Operation
		{
			throw new IllegalOperationError("Load function not defined for association " + owner.reflect.className + "." + definition.property);
		}
		
		private function loading():void
		{
			if (!_isLoading) {
				_isLoading = true;
				dispatchEvent( PropertyChangeEvent.createUpdateEvent(this, "isLoading", false, true) );
			}
		}
		
		private function loaded():void
		{
			if (!_isLoaded) {
				_isLoaded = true;
				_isLoading = false;
				dispatchEvent( PropertyChangeEvent.createUpdateEvent(this, "isLoading", true, false) );
				dispatchEvent( PropertyChangeEvent.createUpdateEvent(this, "isLoaded", false, true) );
			}
		}
		
		private function markEntityForRemoval(entity:Entity):void
		{
			entity.markForRemoval();
		}
		
		private function populateForeignKey(entity:Entity):void
		{
			if (definition.hasForeignKey) {
				if (entity.hasOwnProperty(definition.foreignKey)) {
					entity[definition.foreignKey] = owner.id;
				} else {
					throw new IllegalOperationError("Foreign key '" + definition.foreignKey + "' is not defined on " + entity.reflect.name);
				}
			}
		}
		
		/**
		 * Changes the state of the target for this association back to what it was at the last save.
		 */
		public function revert():void
		{
			
		}
		
		private function reviveEntity(entity:Entity):void
		{
			entity.revive();
		}
		
		public function save(validate:Boolean = true):Operation
		{
			return new EmptyOperation();
		}
		
		/**
		 * The set of <code>Entity</code>s that are dirty and need to be persisted.
		 */
		protected function get dirtyEntities():Array
		{
			return [];
		}
		
		/**
		 * @copy Entity#isDirty
		 */
		public function get isDirty():Boolean
		{
			return dirtyEntities.length > 0;
		}
		
		private var _isLoaded:Boolean;
		[Bindable(event="propertyChange")]
		/**
		 * <code>true</code> if the association objects for this relationship have been loaded.
		 */
		public function get isLoaded():Boolean
		{
			return _isLoaded;
		}
		
		private var _isLoading:Boolean;
		[Bindable(event="propertyChange")]
		/**
		 * <code>true</code> if this association is in the process of loading its data.
		 */
		public function get isLoading():Boolean
		{
			return _isLoading;
		}
		
		private var _definition:AssociationDefinition;
		/**
		 * The relationship model that this association represents.
		 */
		public function get definition():AssociationDefinition
		{
			return _definition;
		}
		
		private var _owner:Entity;
		/**
		 * The instance of the parent owning this association.
		 */
		protected function get owner():Entity
		{
			return _owner;
		}
		
		private var _target:*;
		[Bindable]
		/**
		 * The instance of the the child for the association.
		 */
		public function get target():*
		{
			return _target;
		}
		public function set target(value:*):void
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
			try {
				return flash_proxy::getProperty(name) !== undefined;
			} catch (e:Error) {
				
			}
			return false;
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