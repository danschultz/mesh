package mesh.model.associations
{
	import flash.errors.IllegalOperationError;
	import flash.utils.flash_proxy;
	
	import mesh.Mesh;
	import mesh.core.inflection.humanize;
	import mesh.core.proxy.DataProxy;
	import mesh.core.reflection.Type;
	import mesh.model.Callbacks;
	import mesh.model.Entity;
	import mesh.services.Request;
	
	import mx.events.PropertyChangeEvent;
	
	use namespace flash_proxy;
	
	/**
	 * An association class is a proxy object that contains the references to the objects in
	 * a relationship, where the <em>owner</em> represents the object hosting the association, 
	 * and the <em>object</em> is the actual associated object.
	 * 
	 * @author Dan Schultz
	 */
	public dynamic class Association extends DataProxy
	{
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
			
			_owner = owner;
			_definition = definition;
			
			beforeLoad(loading);
			afterLoad(loaded);
			
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
		
		public function callback(method:String, entity:Entity = null):void
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
		
		private var _loadRequest:Request;
		/**
		 * Executes an operation that will load the object for this association.
		 * 
		 * @return An executing operation.
		 */
		public function load():Request
		{
			if (isLoading) {
				return _loadRequest;
			}
			
			if (!isLoaded) {
				callback("beforeLoad");
				_loadRequest = definition.hasLoadRequest ? definition.loadRequest.apply(owner) : createLoadRequest();
				_loadRequest.addHandler({
					success:function():void
					{
						object = _loadRequest.object;
						callback("afterLoad");
					}
				});
				return _loadRequest;
			}
			
			return new Request(function():void {});
		}
		
		protected function createLoadRequest():Request
		{
			throw new IllegalOperationError("Load function not implemented for " + definition);
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
		
		/**
		 * Changes the state of the object for this association back to what it was at the last save.
		 */
		public function revert():void
		{
			
		}
		
		private function reviveEntity(entity:Entity):void
		{
			entity.revive();
		}
		
		public function save():Request
		{
			var toSave:Array = dirtyEntities;
			if (toSave.length > 0) {
				return Mesh.service((toSave[0] as Entity).reflect.clazz).save(toSave);
			}
			return new Request();
		}
		
		public function toString():String
		{
			return humanize(reflect.className).toLowerCase();
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
		flash_proxy function get definition():AssociationDefinition
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
		
		private var _reflect:Type;
		/**
		 * A reflection on this object.
		 */
		protected function get reflect():Type
		{
			if (_reflect == null) {
				_reflect = Type.reflect(this);
			}
			return _reflect;
		}
	}
}