package mesh.model.associations
{
	import collections.ArraySequence;
	import collections.HashSet;
	
	import flash.errors.IllegalOperationError;
	import flash.utils.flash_proxy;
	
	import mesh.Mesh;
	import mesh.core.functions.closure;
	import mesh.model.Entity;
	import mesh.services.Request;
	
	import mx.collections.ArrayCollection;
	import mx.collections.IList;
	import mx.events.CollectionEvent;
	import mx.events.CollectionEventKind;
	
	use namespace flash_proxy;
	
	public dynamic class AssociationCollection extends Association implements IList
	{
		private var _originalEntities:ArraySequence;
		private var _mirroredEntities:ArraySequence;
		private var _removedEntities:HashSet = new HashSet();
		
		/**
		 * @copy AssociationProxy#AssociationProxy()
		 */
		public function AssociationCollection(source:Entity, definition:HasManyDefinition)
		{
			super(source, definition);
			object = [];
			
			afterLoad(loaded);
			beforeAdd(populateInverseAssociation);
		}
		
		/**
		 * @copy #addItem()
		 */
		public function add(item:Object):void
		{
			addItem(item);
		}
		
		/**
		 * @copy #addItemAt()
		 */
		public function addAt(item:Object, index:int):void
		{
			addItemAt(item, index);
		}
		
		/**
		 * @inheritDoc
		 */
		public function addItem(item:Object):void
		{
			addItemAt(item, length);
		}
		
		/**
		 * @inheritDoc
		 */
		public function addItemAt(item:Object, index:int):void
		{
			callbackIfNotNull("beforeAdd", Entity( item ));
			object.addItemAt(item, index);
		}
		
		/**
		 * Checks if the association has the given entity. This method will only check for entities
		 * that have already been loaded.
		 * 
		 * @param item The item to check.
		 * @return <code>true</code> if the item was found.
		 */
		public function contains(item:Object):Boolean
		{
			return getItemIndex(item) >= 0;
		}
		
		/**
		 * Executes an operation that will remove the given entity from this association and from the
		 * backend. If the entity does not belong to this association, an empty operation is executed
		 * and nothing is performed.
		 * 
		 * @param entity The entity to destroy.
		 * @return An executing operation.
		 */
		public function destroy(entity:Entity):Request
		{
			return contains(entity) ? entity.destroy() : new Request();
		}
		
		/**
		 * @inheritDoc
		 */
		public function getItemAt(index:int, prefetch:int = 0):Object
		{
			return object.getItemAt(index, prefetch);
		}
		
		/**
		 * @inheritDoc
		 */
		public function getItemIndex(item:Object):int
		{
			return _mirroredEntities.indexOf(item);
		}
		
		private function handleEntitiesCollectionChange(event:CollectionEvent):void
		{
			switch (event.kind) {
				case CollectionEventKind.ADD:
					handleEntitiesAdded(event.items);
					break;
				case CollectionEventKind.REMOVE:
					handleEntitiesRemoved(event.items);
					break;
				case CollectionEventKind.RESET:
					handleEntitiesRemoved(_mirroredEntities.difference(object).toArray());
					handleEntitiesAdded(toArray());
					break;
			}
			
			if (event.kind != CollectionEventKind.UPDATE) {
				_mirroredEntities = new ArraySequence(object.source);
			}
			
			dispatchEvent(event.clone());
		}
		
		protected function handleEntitiesAdded(entities:Array):void
		{
			_removedEntities.removeAll(entities);
			
			for each (var entity:Entity in entities) {
				callbackIfNotNull("afterAdd", entity);
			}
		}
		
		protected function handleEntitiesRemoved(entities:Array):void
		{
			_removedEntities.addAll(entities);
			
			for each (var entity:Entity in entities) {
				callbackIfNotNull("afterRemove", entity);
			}
		}
		
		/**
		 * @inheritDoc
		 */
		public function itemUpdated(item:Object, property:Object = null, oldValue:Object = null, newValue:Object = null):void
		{
			object.itemUpdated(item, property, oldValue, newValue);
		}
		
		private function loaded():void
		{
			_originalEntities = new ArraySequence(toArray());
			
			for each (var entity:Entity in this) {
				entity.callback("afterFind");
			}
		}
		
		private function populateInverseAssociation(entity:Entity):void
		{
			if (definition.hasInverse) {
				if (entity.hasOwnProperty(definition.inverse)) {
					entity[definition.inverse].object = owner;
				} else {
					throw new IllegalOperationError("Inverse property '" + definition.inverse + "' not defined on " + entity.reflect.name);
				}
			}
		}
		
		/**
		 * @copy #removeItem()
		 */
		public function remove(item:Object):void
		{
			removeItem(item);
		}
		
		/**
		 * @inheritDoc
		 */
		public function removeAll():void
		{
			object.removeAll();
		}
		
		/**
		 * @copy #removeItemAt()
		 */
		public function removeAt(index:int):void
		{
			removeItemAt(index);
		}
		
		/**
		 * Removes the given entity from this association. This method will only remove entities
		 * that have been loaded into the association.
		 * 
		 * @param item The entity to remove.
		 */
		public function removeItem(item:Object):void
		{
			var index:int = getItemIndex(item);
			if (index >= 0) {
				removeItemAt(index);
			}
		}
		
		/**
		 * @inheritDoc
		 */
		public function removeItemAt(index:int):Object
		{
			callbackIfNotNull("beforeRemove", Entity( getItemAt(index) ));
			return object.removeItemAt(index);
		}
		
		/**
		 * @inheritDoc
		 */
		override public function revert():void
		{
			super.revert();
			
			object = _originalEntities;
			
			for each (var entity:Entity in this) {
				entity.revert();
			}
		}
		
		/**
		 * @inheritDoc
		 */
		override public function save():Request
		{
			if (length > 0) {
				return Mesh.service(getItemAt(0).reflect.clazz).save(toArray());
			}
			return new Request();
		}
		
		/**
		 * @inheritDoc
		 */
		public function setItemAt(item:Object, index:int):Object
		{
			return object.setItemAt(item, index);
		}
		
		/**
		 * @inheritDoc
		 */
		public function toArray():Array
		{
			return object.toArray();
		}
		
		/**
		 * @inheritDoc
		 */
		public function get length():int
		{
			return object.length;
		}
		
		/**
		 * @inheritDoc
		 */
		override protected function get dirtyEntities():Array
		{
			return toArray().concat(_removedEntities.toArray()).filter(closure(function(entity:Entity):Boolean
			{
				return entity.isDirty;
			}));
		}
		
		/**
		 * <code>true</code> if this collection contains entities that have been removed, but not
		 * yet persisted.
		 */
		public function get hasUnsavedRemovedEntities():Boolean
		{
			for each (var entity:Entity in _removedEntities) {
				if (entity.isPersisted) {
					return true;
				}
			}
			return false;
		}
		
		/**
		 * @inheritDoc
		 */
		override flash_proxy function get object():*
		{
			return super.object;
		}
		override flash_proxy function set object(value:*):void
		{
			if (value != null && (!(value is Array) && !value.hasOwnProperty("toArray"))) {
				throw new ArgumentError("AssociationCollection.object must be an Array, have a toArray method, or be null.");
			}
			
			if (value != object) {
				if (object != null) {
					object.removeEventListener(CollectionEvent.COLLECTION_CHANGE, handleEntitiesCollectionChange);
				}
				
				if (value != null && value.hasOwnProperty("toArray")) {
					value = value.toArray();
				}
				
				super.object = new ArrayCollection(value);
				
				if (_mirroredEntities == null) {
					_mirroredEntities = new ArraySequence(value);
				}
				
				object.addEventListener(CollectionEvent.COLLECTION_CHANGE, handleEntitiesCollectionChange);
				object.dispatchEvent(new CollectionEvent(CollectionEvent.COLLECTION_CHANGE, false, false, CollectionEventKind.RESET));
			}
		}
		
		/**
		 *  @inheritDoc
		 */
		override flash_proxy function nextName(index:int):String
		{
			return (index-1).toString();
		}
		
		private var _iteratingItems:Array;
		private var _len:int;
		/**
		 * @inheritDoc
		 */
		override flash_proxy function nextNameIndex(index:int):int
		{
			if (index == 0) {
				_iteratingItems = toArray();
				_len = _iteratingItems.length;
			}
			return index < _len ? index+1 : 0;
		}
		
		/**
		 * @inheritDoc
		 */
		override flash_proxy function nextValue(index:int):*
		{
			return _iteratingItems[index-1];
		}
	}
}