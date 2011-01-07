package mesh.associations
{
	import collections.HashMap;
	import collections.HashSet;
	import collections.ISet;
	
	import flash.errors.IllegalOperationError;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.utils.Proxy;
	import flash.utils.describeType;
	import flash.utils.flash_proxy;
	import flash.utils.setTimeout;
	
	import mesh.Entity;
	import mesh.Visitor;
	
	import mx.events.PropertyChangeEvent;
	
	import operations.EmptyOperation;
	import operations.FinishedOperationEvent;
	import operations.Operation;
	import operations.ResultOperationEvent;
	
	import reflection.className;
	import reflection.clazz;

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
		
		public function accept(visitor:Visitor):void
		{
			visitor.visit(this);
		}
		
		/**
		 * Returns the set of entities that are dirty for this association that need to be
		 * persisted.
		 * 
		 * @return A set of <code>Entity</code>s.
		 */
		public function findDirtyEntities():ISet
		{
			return new HashSet();
		}
		
		/**
		 * Returns the set of entities that have been removed from this association.
		 * 
		 * @return A set of <code>Entity</code>s.
		 */
		public function findRemovedEntities():ISet
		{
			return new HashSet();
		}
		
		public function fromVO(vo:Object, options:Object = null):void
		{
			
		}
		
		private static const VO_TO_ENTITY:HashMap = new HashMap();
		protected function createEntityFromVOMapping(vo:Object, options:Object = null):Entity
		{
			var voType:Class = clazz(vo);
			if (!VO_TO_ENTITY.containsKey(voType)) {
				for each (var metadataXML:XML in describeType(vo)..metadata.(@name == "Entity")) {
					VO_TO_ENTITY.put(voType, metadataXML.parent().@type);
					break;
				}
			}
			
			var entityType:Class = VO_TO_ENTITY.grab(voType);
			if (entityType == null) {
				throw new IllegalOperationError("Entity mapping not found for " + className(vo));
			}
			
			var entity:Entity = new entityType();
			entity.fromVO(vo, options);
			return entity;
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
			var oldValue:Boolean = isLoaded;
			_isLoaded = true;
			dispatchEvent(PropertyChangeEvent.createUpdateEvent(this, "isLoaded", oldValue, isLoaded));
		}
		
		/**
		 * Changes the state of the target for this association back to what it was at the
		 * last save.
		 */
		public function revert():void
		{
			
		}
		
		/**
		 * @copy Entity#isDirty
		 */
		public function get isDirty():Boolean
		{
			return false;
		}
		
		private var _isLoaded:Boolean;
		[Bindable(event="propertyChange")]
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
		public function get relationship():Relationship
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