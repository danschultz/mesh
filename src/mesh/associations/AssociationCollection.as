package mesh.associations
{
	import collections.ArraySequence;
	import collections.HashSet;
	
	import flash.utils.flash_proxy;
	import flash.utils.setTimeout;
	
	import mesh.Entity;
	import mesh.Mesh;
	import mesh.core.functions.closure;
	import mesh.core.reflection.Type;
	import mesh.core.reflection.className;
	import mesh.core.reflection.reflect;
	
	import mx.collections.ArrayCollection;
	import mx.collections.IList;
	import mx.events.CollectionEvent;
	import mx.events.CollectionEventKind;
	
	import operations.EmptyOperation;
	import operations.Operation;
	
	use namespace flash_proxy;
	
	public dynamic class AssociationCollection extends AssociationProxy implements IList
	{
		private var _originalEntities:ArraySequence;
		private var _mirroredEntities:ArraySequence;
		private var _removedEntities:HashSet = new HashSet();
		
		/**
		 * @copy AssociationProxy#AssociationProxy()
		 */
		public function AssociationCollection(source:Entity, relationship:Relationship)
		{
			super(source, relationship);
			target = [];
			
			afterLoad(function(proxy:AssociationCollection):void
			{
				_originalEntities = new ArraySequence(toArray());
				
				for each (var entity:Entity in proxy) {
					entity.callback("afterFind");
				}
			});
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
			target.addItem(item);
		}
		
		/**
		 * @inheritDoc
		 */
		public function addItemAt(item:Object, index:int):void
		{
			target.addItemAt(item, index);
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
		public function destroy(entity:Entity):Operation
		{
			var operation:Operation = new EmptyOperation();
			if (contains(entity)) {
				operation = entity.createDestroy();
			}
			setTimeout(operation.execute, Mesh.DELAY);
			return operation;
		}
		
		/**
		 * @inheritDoc
		 */
		override public function fromVO(vo:Object, options:Object = null):void
		{
			if (!(vo is Array) && !(vo is IList)) {
				throw new ArgumentError("Expected an Array or IList, but got a " + className(vo));
			}
			
			var items:Array = [];
			for each (var item:Object in vo) {
				items.push(createEntityFromVOMapping(item, options));
			}
			target = items;
		}
		
		/**
		 * @inheritDoc
		 */
		public function getItemAt(index:int, prefetch:int = 0):Object
		{
			return target.getItemAt(index, prefetch);
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
					handleEntitiesRemoved(_mirroredEntities.difference(target).toArray());
					handleEntitiesAdded(toArray());
					break;
			}
			
			if (event.kind != CollectionEventKind.UPDATE) {
				_mirroredEntities = new ArraySequence(target.source);
			}
			
			dispatchEvent(event.clone());
		}
		
		protected function handleEntitiesAdded(entities:Array):void
		{
			_removedEntities.removeAll(entities);
			
			for each (var entity:Entity in entities) {
				entity.afterDestroy(entityDestroyed);
				entity.revive();
			}
		}
		
		protected function handleEntitiesRemoved(entities:Array):void
		{
			_removedEntities.addAll(entities);
			
			for each (var entity:Entity in entities) {
				entity.markForRemoval();
			}
		}
		
		/**
		 * @inheritDoc
		 */
		public function itemUpdated(item:Object, property:Object = null, oldValue:Object = null, newValue:Object = null):void
		{
			target.itemUpdated(item, property, oldValue, newValue);
		}
		
		private function entityDestroyed(entity:Entity):void
		{
			remove(entity);
			_removedEntities.remove(entity);
			entity.removeCallback(entityDestroyed);
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
			target.removeAll();
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
			return target.removeItemAt(index);
		}
		
		/**
		 * @inheritDoc
		 */
		override public function revert():void
		{
			super.revert();
			
			target = _originalEntities;
			
			for each (var entity:Entity in this) {
				entity.revert();
			}
		}
		
		/**
		 * @inheritDoc
		 */
		public function setItemAt(item:Object, index:int):Object
		{
			return target.setItemAt(item, index);
		}
		
		/**
		 * @inheritDoc
		 */
		public function toArray():Array
		{
			return target.toArray();
		}
		
		/**
		 * Returns an array that contains the VO's for the entities of this collection.
		 * 
		 * @param options Any options.
		 * @return An array of VO's.
		 */
		public function toVO(options:Object = null):Object
		{
			var result:Array = [];
			for each (var entity:Entity in this) {
				result.push(entity.toVO(options));
			}
			
			if (options.hasOwnProperty("type")) {
				var type:Type = reflect(options.type);
				if (type.isA(ArrayCollection)) {
					return new ArrayCollection(result);
				} else if (type.isA(Array)) {
					return result;
				} else {
					throw new ArgumentError("Type must be an Array or ArrayCollection, but was " + type)
				}
			}
			
			return result;
		}
		
		/**
		 * @inheritDoc
		 */
		public function get length():int
		{
			return target.length;
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
		override public function get target():*
		{
			return super.target;
		}
		override public function set target(value:*):void
		{
			if (value != null && (!(value is Array) && !value.hasOwnProperty("toArray"))) {
				throw new ArgumentError("AssociationCollection.target must be an Array, have a toArray method, or be null.");
			}
			
			if (value != target) {
				if (target != null) {
					target.removeEventListener(CollectionEvent.COLLECTION_CHANGE, handleEntitiesCollectionChange);
				}
				
				if (value != null && value.hasOwnProperty("toArray")) {
					value = value.toArray();
				}
				
				super.target = new ArrayCollection(value);
				
				if (_mirroredEntities == null) {
					_mirroredEntities = new ArraySequence(value);
				}
				
				target.addEventListener(CollectionEvent.COLLECTION_CHANGE, handleEntitiesCollectionChange);
				target.dispatchEvent(new CollectionEvent(CollectionEvent.COLLECTION_CHANGE, false, false, CollectionEventKind.RESET));
			}
		}
		
		/**
		 * @inheritDoc
		 */
		override flash_proxy function callProperty(name:*, ...parameters):*
		{
			for each (var entity:Entity in this) {
				entity[name].apply(null, parameters);
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