package mesh.model.associations
{
	import flash.errors.IllegalOperationError;
	
	import mesh.model.Record;
	
	import mx.events.PropertyChangeEvent;
	
	/**
	 * The base class for any association that links to a single record.
	 * 
	 * @author Dan Schultz
	 */
	public class HasAssociation extends Association
	{
		/**
		 * @copy AssociationProxy#AssociationProxy()
		 */
		public function HasAssociation(owner:Record, property:String, options:Object = null)
		{
			super(owner, property, options);
			checkForRequiredFields();
		}
		
		/**
		 * @inheritDoc
		 */
		override protected function associate(record:Record):void
		{
			super.associate(record);
			populateForeignKey();
			record.addEventListener(PropertyChangeEvent.PROPERTY_CHANGE, handleAssociatedRecordPropertyChange);
		}
		
		private function checkForRequiredFields():void
		{
			if (recordType == null) throw new IllegalOperationError("Undefined record type for " + this);
			if (options.foreignKey != null && !owner.hasOwnProperty(options.foreignKey)) throw new IllegalOperationError("Undefined foreign key '" + options.foreignKey + " for " + this);
		}
		
		private function handleAssociatedRecordPropertyChange(event:PropertyChangeEvent):void
		{
			if (event.property == "id") {
				populateForeignKey();
			}
		}
		
		/**
		 * @inheritDoc
		 */
		override public function initialize():void
		{
			super.initialize();
			owner[property] = store.query(recordType).find(owner[foreignKey]);
		}
		
		private function populateForeignKey():void
		{
			// If the foreign key is undefined, try to automagically set it.
			var key:String = foreignKey;
			
			if (owner.hasOwnProperty(key)) {
				owner[key] = object.id;
			}
		}
		
		private function unassociateForeignKey():void
		{
			// If the foreign key is undefined, try to automagically set it.
			var key:String = foreignKey;
			
			if (owner.hasOwnProperty(key)) {
				owner[key] = null;
			}
		}
		
		/**
		 * @inheritDoc
		 */
		override protected function unassociate(record:Record):void
		{
			super.unassociate(record);
			record.removeEventListener(PropertyChangeEvent.PROPERTY_CHANGE, handleAssociatedRecordPropertyChange);
			unassociateForeignKey();
		}
		
		/**
		 * The property on the owner that defines the foreign key to load this association.
		 */
		public function get foreignKey():String
		{
			return options.foreignKey != null ? options.foreignKey : property + "Id";
		}
		
		/**
		 * The associated type of record. If the type is not defined as an option, then the association
		 * will look up the type defined on the record through reflection.
		 */
		protected function get recordType():Class
		{
			try {
				return options.recordType != null ? options.recordType : owner.reflect.property(property).type.clazz;
			} catch (e:Error) {
				
			}
			return null;
		}
		
		/**
		 * @inheritDoc
		 */
		override public function set object(value:*):void
		{
			if (object != null) unassociate(object);
			super.object = value;
			if (object != null) associate(object);
		}
	}
}