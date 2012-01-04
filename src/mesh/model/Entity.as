package mesh.model
{
	import flash.errors.IllegalOperationError;
	import flash.events.EventDispatcher;
	
	import mesh.core.inflection.humanize;
	import mesh.core.object.copy;
	import mesh.core.reflection.Type;
	import mesh.model.associations.HasManyAssociation;
	import mesh.model.associations.HasOneAssociation;
	import mesh.model.store.Store;
	import mesh.model.validators.Errors;
	import mesh.model.validators.Validator;
	
	import mx.events.PropertyChangeEvent;
	
	/**
	 * An entity.
	 * 
	 * @author Dan Schultz
	 */
	public class Entity extends EventDispatcher
	{
		private var _associations:Associations;
		private var _aggregates:Aggregates;
		
		/**
		 * Constructor.
		 * 
		 * @param values A hash of values to set on the entity.
		 */
		public function Entity(values:Object = null)
		{
			super();
			
			_associations = new Associations(this);
			_aggregates = new Aggregates(this);
			
			copy(values, this);
			addEventListener(PropertyChangeEvent.PROPERTY_CHANGE, handlePropertyChange);
		}
		
		/**
		 * @copy mesh.model.Aggregates#add()
		 */
		protected function aggregate(property:String, type:Class, mappings:Array):void
		{
			_aggregates.add(property, type, mappings);
		}
		
		/**
		 * Maps a has-one association to a property on this entity.
		 * 
		 * @param property The property that owns the association.
		 * @param query The query to retrieve data for the association.
		 * @param options Any options to configure the association.
		 * @return The association object.
		 */
		protected function hasOne(property:String, options:Object = null):void
		{
			_associations.map(property, new HasOneAssociation(this, property, options));
		}
		
		/**
		 * Maps up a has-many association to a property on this entity.
		 * 
		 * @param property The property that owns the association.
		 * @param query The query to retrieve data for the association.
		 * @param options Any options to configure the association.
		 * @return The association object.
		 */
		protected function hasMany(property:String, options:Object = null):void
		{
			var association:HasManyAssociation = new HasManyAssociation(this, property, options);
			this[property] = association;
			_associations.map(property, association);
		}
		
		/**
		 * Checks if two entities are equal.  By default, two entities are equal
		 * when they are of the same type, and their ID's are the same.
		 * 
		 * @param entity The entity to check.
		 * @return <code>true</code> if the entities are equal.
		 */
		public function equals(obj:Object):Boolean
		{
			return obj != null && (this === obj || (reflect.clazz == obj.reflect.clazz && id === obj.id));
		}
		
		private function handlePropertyChange(event:PropertyChangeEvent):void
		{
			propertyChanged(event.property.toString(), event.oldValue, event.newValue);
		}
		
		/**
		 * Returns a generated hash value for this entity.  Two entities that represent
		 * the same data should return the same hash code.
		 * 
		 * @return A hash value.
		 */
		public function hashCode():Object
		{
			return id;
		}
		
		/**
		 * Runs the validations defined for this entity and returns <code>true</code> if any
		 * validations failed.
		 * 
		 * @return <code>true</code> if any validations failed.
		 * 
		 * @see #isValid()
		 * @see #validate()
		 */
		public function isInvalid():Boolean
		{
			return !isValid();
		}
		
		/**
		 * Runs the validations defined for this entity and returns <code>true</code> if all
		 * validations passed.
		 * 
		 * @return <code>true</code> if all validations passed.
		 * 
		 * @see #isInvalid()
		 * @see #validate()
		 */
		public function isValid():Boolean
		{
			return validate().length == 0;
		}
		
		/**
		 * Marks a property on the entity as being dirty. This method allows sub-classes to manually 
		 * manage when a property changes.
		 * 
		 * @param property The property that was changed.
		 * @param oldValue The property's old value.
		 * @param newValue The property's new value.
		 */
		protected function propertyChanged(property:String, oldValue:Object, newValue:Object):void
		{
			if (!associations.isAssociation(property)) {
				changes.changed(property, oldValue, newValue);
				_aggregates.changed(property);
			}
		}
		
		/**
		 * @private
		 */
		override public function toString():String
		{
			return humanize(reflect.className);
		}
		
		/**
		 * Runs the validations defined on this entity and returns the set of errors for
		 * any validations that failed. If all validations passed, this method returns an
		 * empty array.
		 * 
		 * <p>
		 * Calling this method will also populate the <code>Entity.errors</code> property with
		 * the validation results.
		 * </p>
		 * 
		 * @see #isInvalid()
		 * @see #isValid()
		 * @see #errors
		 */
		private function validate():Array
		{
			errors.clear();
			
			for (var reflection:Type = reflect; reflection != null && reflection.clazz != Entity; reflection = reflection.parent) {
				var validations:Object = reflection.clazz["validate"];
				for (var property:String in validations) {
					for each (var validation:Object in validations[property]) {
						var ValidatorClass:Class = validation.validator;
						validation.property = property;
						(new ValidatorClass(validation) as Validator).validate(this);
					}
				}
			}
			return errors.toArray();
		}
		
		/**
		 * The hash the associations defined on this entity. The associations hash is defined as 
		 * key-value pairs where the key is the property the associaiton is defined on, and the
		 * value is the association object.
		 */
		public function get associations():Associations
		{
			return _associations;
		}
		
		private var _changes:Changes;
		/**
		 * @copy Changes
		 */
		public function get changes():Changes
		{
			if (_changes == null) {
				_changes = new Changes(this);
			}
			return _changes;
		}
		
		private var _errors:Errors;
		/**
		 * A set of <code>ValidationResult</code>s that failed during the last call to 
		 * <code>validate()</code>.
		 * 
		 * @see #validate()
		 */
		public function get errors():Errors
		{
			if (_errors == null) {
				_errors = new Errors(this);
			}
			return _errors;
		}
		
		private var _id:*;
		/**
		 * An object that represents the ID for this entity.
		 */
		public function get id():*
		{
			return _id;
		}
		public function set id(value:*):void
		{
			_id = value;
		}
		
		private var _reflect:Type;
		/**
		 * A reflection that contains the properties, methods and metadata defined on this
		 * entity.
		 */
		public function get reflect():Type
		{
			if (_reflect == null) {
				_reflect = Type.reflect(this);
			}
			return _reflect;
		}
		
		private var _store:Store;
		/**
		 * The data store that this entity belongs to.
		 */
		public function get store():Store
		{
			return _store;
		}
		public function set store(value:Store):void
		{
			if (_store != null) {
				throw new IllegalOperationError("Cannot reset store on Entity.");
			}
			_store = value;
		}
	}
}
