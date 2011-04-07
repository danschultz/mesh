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
	import mesh.IPersistable;
	import mesh.Mesh;
	import mesh.SaveBatch;
	import mesh.core.reflection.className;
	
	import mx.events.PropertyChangeEvent;
	
	import operations.EmptyOperation;
	import operations.FinishedOperationEvent;
	import operations.Operation;
	import operations.ResultOperationEvent;

	/**
	 * An association class is a proxy object that contains the references to the objects in
	 * a relationship, where the <em>owner</em> represents the object hosting the association, 
	 * and the <em>target</em> is the actual associated object.
	 * 
	 * @author Dan Schultz
	 */
	public dynamic class Association extends Proxy implements IEventDispatcher, IPersistable
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
		}
		
		private function addCallback(method:String, block:Function):void
		{
			_callbacks.addCallback(method, block);
		}
		
		protected function beforeLoad(block:Function):void
		{
			addCallback("beforeLoad", block);
		}
		
		protected function afterLoad(block:Function):void
		{
			addCallback("afterLoad", block);
		}
		
		public function callback(method:String):void
		{
			_callbacks.callback(method);
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
			var operation:Operation = createLoadOperation();
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
		
		/**
		 * Populates the belongs to association on the given entity that represents the inverse
		 * of this association.
		 * 
		 * @param entity The entity to populate.
		 */
		protected function populateBelongsToAssociation(entity:Entity):void
		{
			for each (var association:Association in entity.associations) {
				if (association is BelongsToAssociation && definition.target == association.definition.owner) {
					association.target = owner;
					break;
				}
			}
		}
		
		/**
		 * Changes the state of the target for this association back to what it was at the last save.
		 */
		public function revert():void
		{
			
		}
		
		public function save(validate:Boolean = true):Operation
		{
			var operation:Operation = new SaveBatch().add(this).build(validate);
			setTimeout(operation.execute, Mesh.DELAY);
			return operation;
		}
		
		public function batch(batch:SaveBatch):void
		{
			batch.add.apply(null, dirtyEntities);
		}
		
		private function setBindableProperty(property:String, getter:Function, setter:Function):void
		{
			var oldValue:* = getter();
			setter();
			dispatchEvent(PropertyChangeEvent.createUpdateEvent(this, property, oldValue, getter()));
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