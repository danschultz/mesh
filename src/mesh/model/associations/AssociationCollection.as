package mesh.model.associations
{
	import flash.utils.flash_proxy;
	
	import mesh.mesh_internal;
	import mesh.model.Record;
	import mesh.model.store.ResultsList;
	import mesh.operations.Operation;
	
	import mx.collections.IList;
	import mx.collections.ListCollectionView;
	import mx.events.CollectionEvent;
	
	use namespace mesh_internal;
	use namespace flash_proxy;
	
	public class AssociationCollection extends Association implements IList
	{
		private var _list:ListCollectionView;
		private var _results:ResultsList;
		private var _query:Function;
		
		/**
		 * @copy Association#Association()
		 */
		public function AssociationCollection(source:Record, property:String, query:Function, options:Object = null)
		{
			super(source, property, options);
			
			_query = query;
			
			_list = new ListCollectionView();
			_list.addEventListener(CollectionEvent.COLLECTION_CHANGE, handleListCollectionChange);
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
			associate(Record( item ));
		}
		
		/**
		 * @inheritDoc
		 */
		public function getItemAt(index:int, prefetch:int = 0):Object
		{
			return _list.getItemAt(index, prefetch);
		}
		
		/**
		 * @inheritDoc
		 */
		public function getItemIndex(item:Object):int
		{
			return _list.getItemIndex(item);
		}
		
		private function handleListCollectionChange(event:CollectionEvent):void
		{
			dispatchEvent(event);
		}
		
		/**
		 * @inheritDoc
		 */
		override mesh_internal function initialize():void
		{
			super.initialize();
			_list.list = _results = _query(store);
		}
		
		/**
		 * @inheritDoc
		 */
		public function itemUpdated(item:Object, property:Object = null, oldValue:Object = null, newValue:Object = null):void
		{
			_list.itemUpdated(item, property, oldValue, newValue);
		}
		
		/**
		 * @copy mesh.model.store.ResultsList#load()
		 */
		public function load():*
		{
			if (_results != null) {
				_results.load();
			}
			return this;
		}
		
		/**
		 * @copy mesh.model.store.ResultsList#refresh()
		 */
		public function refresh():*
		{
			if (_results != null) {
				_results.refresh();
			}
			return this;
		}
		
		/**
		 * @inheritDoc
		 */
		public function removeAll():void
		{
			
		}
		
		/**
		 * @inheritDoc
		 */
		public function removeItemAt(index:int):Object
		{
			return null;
		}
		
		/**
		 * @inheritDoc
		 */
		public function setItemAt(item:Object, index:int):Object
		{
			return null;
		}
		
		/**
		 * @inheritDoc
		 */
		public function toArray():Array
		{
			return _list.toArray();
		}
		
		/**
		 * @copy mesh.model.store.ResultsList#isLoaded
		 */
		public function get isLoaded():Boolean
		{
			return _results != null ? _results.isLoaded : false;
		}
		
		/**
		 * @inheritDoc
		 */
		public function get length():int
		{
			return _list.length;
		}
		
		/**
		 * @copy mesh.model.store.ResultsList#loadOperation
		 */
		public function get loadOperation():Operation
		{
			return _results != null ? _results.loadOperation : null;
		}
		
		// Proxy methods to support for each..in loops.
		
		/**
		 * @private
		 */
		override flash_proxy function nextName(index:int):String
		{
			return (index-1).toString();
		}
		
		private var _iteratingItems:Array;
		private var _len:int;
		/**
		 * @private
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
		 * @private
		 */
		override flash_proxy function nextValue(index:int):*
		{
			return _iteratingItems[index-1];
		}
	}
}