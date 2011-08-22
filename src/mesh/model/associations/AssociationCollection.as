package mesh.model.associations
{
	import mesh.model.Entity;
	
	import mx.collections.IList;
	import mx.events.CollectionEvent;
	import mx.events.CollectionEventKind;
	import mx.events.PropertyChangeEvent;
	
	public class AssociationCollection extends Association
	{
		private var _snapshot:Array = [];
		
		/**
		 * @copy AssociationProxy#AssociationProxy()
		 */
		public function AssociationCollection(source:Entity, options:Object = null)
		{
			super(source, options);
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
				_snapshot = list.toArray();
			}
		}
		
		private function handleEntitiesAdded(items:Array):void
		{
			for each (var entity:Entity in items) {
				associate(entity);
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
				handleEntitiesRemoved(change.oldValue);
				handleEntitiesAdded(change.newValue);
			}
		}
		
		private function handleEntitiesReset():void
		{
			for each (var oldEntity:Entity in _snapshot) {
				if (list.getItemIndex(oldEntity) == -1) {
					handleEntitiesRemoved([oldEntity]);
				}
			}
			
			for each (var newEntity:Entity in list.toArray()) {
				if (_snapshot.indexOf(newEntity) == -1) {
					handleEntitiesAdded([newEntity]);
				}
			}
		}
		
		/**
		 * The list that this association is managing.
		 */
		protected function get list():IList
		{
			return IList( object );
		}
		
		/**
		 * @inheritDoc
		 */
		override public function set object(value:*):void
		{
			if (list != null) list.removeEventListener(CollectionEvent.COLLECTION_CHANGE, handleListCollectionChange);
			super.object = value;
			if (list != null) list.addEventListener(CollectionEvent.COLLECTION_CHANGE, handleListCollectionChange);
		}
	}
}