package mesh.model.associations
{
	import mesh.model.Entity;
	
	import mx.collections.ListCollectionView;
	import mx.events.CollectionEvent;
	import mx.events.CollectionEventKind;
	import mx.events.PropertyChangeEvent;
	
	public class AssociationCollection extends Association
	{
		private var _list:ListCollectionView;
		private var _snapshot:Array = [];
		
		/**
		 * @copy AssociationProxy#AssociationProxy()
		 */
		public function AssociationCollection(source:Entity, property:String, options:Object = null)
		{
			super(source, property, options);
			
			_list = new ListCollectionView();
			_list.addEventListener(CollectionEvent.COLLECTION_CHANGE, handleListCollectionChange);
		}
		
		/**
		 * @inheritDoc
		 */
		override protected function entityDestroyed(entity:Entity):void
		{
			_list.removeItemAt(_list.getItemIndex(entity));
			associate(entity, false);
		}
		
		/**
		 * @inheritDoc
		 */
		override protected function entityRevived(entity:Entity):void
		{
			if (!_list.contains(entity)) {
				_list.addItem(entity);
			}
		}
		
		private function handleListCollectionChange(event:CollectionEvent):void
		{
			switch (event.kind) {
				case CollectionEventKind.ADD:
					handleEntitiesAdded(event.items);
					break;
				case CollectionEventKind.REMOVE:
					handleEntitiesRemoved(event.items);
					break;
				case CollectionEventKind.REPLACE:
					handleEntitiesReplaced(event.items);
					break;
				case CollectionEventKind.RESET:
					handleEntitiesReset();
					break;
			}
			
			if (event.kind != CollectionEventKind.UPDATE) {
				_snapshot = _list.toArray();
			}
		}
		
		private function handleEntitiesAdded(items:Array):void
		{
			for each (var entity:Entity in items) {
				associate(entity, true);
			}
		}
		
		private function handleEntitiesRemoved(items:Array):void
		{
			for each (var entity:Entity in items) {
				unassociate(entity);
			}
		}
		
		private function handleEntitiesReplaced(items:Array):void
		{
			for each (var change:PropertyChangeEvent in items) {
				handleEntitiesRemoved([change.oldValue]);
				handleEntitiesAdded([change.newValue]);
			}
		}
		
		private function handleEntitiesReset():void
		{
			for each (var oldEntity:Entity in _snapshot) {
				if (_list.getItemIndex(oldEntity) == -1) {
					handleEntitiesRemoved([oldEntity]);
				}
			}
			
			for each (var newEntity:Entity in _list.toArray()) {
				if (_snapshot.indexOf(newEntity) == -1) {
					handleEntitiesAdded([newEntity]);
				}
			}
		}
		
		/**
		 * @inheritDoc
		 */
		override public function set object(value:*):void
		{
			super.object = value;
			_list.list = value;
		}
	}
}