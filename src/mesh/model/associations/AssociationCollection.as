package mesh.model.associations
{
	import collections.ArraySequence;
	import collections.HashSet;
	
	import flash.errors.IllegalOperationError;
	import flash.utils.IDataInput;
	import flash.utils.IDataOutput;
	import flash.utils.IExternalizable;
	import flash.utils.flash_proxy;
	
	import mesh.model.Entity;
	
	import mx.collections.ArrayCollection;
	import mx.collections.IList;
	import mx.events.CollectionEvent;
	import mx.events.CollectionEventKind;
	
	use namespace flash_proxy;
	
	[RemoteClass(alias="mesh.model.associations.AssociationCollection")]
	
	public dynamic class AssociationCollection extends Association implements IList, IExternalizable
	{
		private var _originalEntities:Array;
		private var _mirroredEntities:ArraySequence;
		private var _removedEntities:HashSet = new HashSet();
		
		/**
		 * @copy AssociationProxy#AssociationProxy()
		 */
		public function AssociationCollection(source:Entity, definition:HasManyDefinition)
		{
			super(source, definition);
			object = [];
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
			dispatchEvent(event.clone());
		}
		
		/**
		 * @inheritDoc
		 */
		public function itemUpdated(item:Object, property:Object = null, oldValue:Object = null, newValue:Object = null):void
		{
			object.itemUpdated(item, property, oldValue, newValue);
		}
		
		private function populateInverseAssociation(entity:Entity):void
		{
			if (definition.hasInverse) {
				if (entity.hasOwnProperty(definition.inverse)) {
					// if the inverse relationship is an association, then we populate the inverse 
					// association's object. otherwise, we just set the property to the association's owner.
					if (entity[definition.inverse] is Association) {
						entity[definition.inverse].object = owner;
					} else {
						entity[definition.inverse] = owner;
					}
				} else {
					throw new IllegalOperationError("Inverse property '" + definition.inverse + "' not defined on " + entity.reflect.name);
				}
			}
		}
		
		/**
		 * @inheritDoc
		 */
		public function readExternal(input:IDataInput):void
		{
			object = input.readObject();
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
			return object.removeItemAt(index);
		}
		
		/**
		 * @inheritDoc
		 */
		public function setItemAt(item:Object, index:int):Object
		{
			return object.setItemAt(item, index);
		}
		
		private function snapshot():void
		{
			_originalEntities = toArray();
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
		public function writeExternal(output:IDataOutput):void
		{
			output.writeObject(object);
		}
		
		/**
		 * <code>true</code> if the collection doesn't contain any elements.
		 */
		public function get isEmpty():Boolean
		{
			return length == 0;
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
		override flash_proxy function get object():*
		{
			return super.object;
		}
		override flash_proxy function set object(value:*):void
		{
			if (value is Entity) {
				value = [value];
			}
			
			if (value != null && (!(value is Array) && !value.hasOwnProperty("toArray"))) {
				throw new ArgumentError("AssociationCollection.object must be an Array, have a 'toArray' method, or be null.");
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