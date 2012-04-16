package mesh.model.associations
{
	import flash.errors.IllegalOperationError;
	
	import mesh.model.ID;
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
			owner.addEventListener(PropertyChangeEvent.PROPERTY_CHANGE, handleOwnerPropertyChange);
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
		
		private function handleOwnerPropertyChange(event:PropertyChangeEvent):void
		{
			if (event.property == foreignKey) {
				populateRecord();
			}
		}
		
		private function populateRecord():void
		{
			owner[property] = ID.isPopulated(owner, foreignKey) ? store.query(recordType).find(owner[foreignKey]) : null;
		}
		
		private function populateForeignKey():void
		{
			// If the foreign key is undefined, try to automagically set it.
			var key:String = foreignKey;
			
			if (owner.hasOwnProperty(key)) {
				owner[key] = _record.id;
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
		
		private var _record:Record;
		/**
		 * @inheritDoc
		 */
		override public function set object(value:*):void
		{
			if (value != _record) {
				if (_record != null) unassociate(_record);
				_record = value;
				super.object = _record;
				if (_record != null) associate(_record);
			}
		}
	}
}