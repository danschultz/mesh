package mesh.model
{
	import flash.events.EventDispatcher;
	import flash.utils.flash_proxy;
	
	import mesh.core.inflection.humanize;
	import mesh.core.object.copy;
	import mesh.core.reflection.Type;
	import mesh.model.associations.HasManyAssociation;
	import mesh.model.associations.HasOneAssociation;
	import mesh.model.query.Query;
	import mesh.model.store.Store;
	import mesh.model.validators.Errors;
	import mesh.model.validators.Validator;
	
	import mx.events.PropertyChangeEvent;
	
	use namespace flash_proxy;
	
	/**
	 * An entity.
	 * 
	 * @author Dan Schultz
	 */
	public class Entity extends EventDispatcher
	{
		/**
		 * The generic lifecycle state for when the entity has just been
		 * created, but not loaded.
		 */
		public static const EMPTY:int = 0x00000;
		
		/**
		 * The generic lifecycle state for when the entity is new.
		 */
		public static const INITIALIZED:int = 0x00100;
		
		/**
		 * The generic lifecyle state for when an entity exists locally and on the server.
		 */
		public static const PERSISTED:int = 0x00200;
		
		/**
		 * The generic lifecycle state for when the entity has been destroyed.
		 */
		public static const DESTROYED:int = 0x00400;
		
		/**
		 * The generic lifecycle state for when there are changes to be committed.
		 */
		public static const DIRTY:int = 0x00001;
		
		/**
		 * The generic lifecycle state for when there's an error after a commit.
		 */
		public static const ERRORED:int = 0x01000;
		
		/**
		 * The generic lifecycle state for when an entity is either loading or committing.
		 */
		public static const BUSY:int = 0x02000;
		
		/**
		 * The generic lifecycle state for when the changes have been synced with the
		 * backend.
		 */
		public static const SYNCED:int = 0x04000;
		
		private var _associations:Associations;
		private var _aggregates:Aggregates;
		
		/**
		 * Constructor.
		 */
		public function Entity(values:Object = null)
		{
			super();
			
			_associations = new Associations(this);
			_aggregates = new Aggregates(this);
			
			copy(values, this);
			addEventListener(PropertyChangeEvent.PROPERTY_CHANGE, handlePropertyChange);
		}
		
		protected function aggregate(property:String, type:Class, mappings:Array):void
		{
			_aggregates.add(property, type, mappings);
		}
		
		/**
		 * Sets up a has-one association for a property.
		 * 
		 * @param property The property that owns the association.
		 * @param query The query to retrieve data for the association.
		 * @param options Any options to configure the association.
		 * @return The association object.
		 */
		protected function hasOne(property:String, query:Query, options:Object = null):void
		{
			_associations.map(property, new HasOneAssociation(this, query, options));
		}
		
		/**
		 * Sets up a has-many association for a property.
		 * 
		 * @param property The property that owns the association.
		 * @param query The query to retrieve data for the association.
		 * @param options Any options to configure the association.
		 * @return The association object.
		 */
		protected function hasMany(property:String, query:Query, options:Object = null):void
		{
			_associations.map(property, new HasManyAssociation(this, query, options));
		}
		
		/**
		 * Puts the entity into a busy lifecycle state. This state signifies that the entity is
		 * busy either retrieving or committing data to the data source.
		 * 
		 * @return This instance.
		 */
		public function busy():Entity
		{
			state = (state & ~0xF000) | BUSY;
			return this;
		}
		
		/**
		 * Puts the entity into an errored lifecycle state. This state signifies that an error 
		 * occurred after a load or commit.
		 * 
		 * @return This instance.
		 */
		public function errored():Entity
		{
			state = (state & ~0xF000) | ERRORED;
			return this;
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
			return obj != null && (this === obj || (obj is Entity && isPersisted && id === obj.id));
		}
		
		/**
		 * Marks this entity as destroyed and dirty.
		 * 
		 * @return This instance.
		 */
		public function destroy():Entity
		{
			return destroyed().dirty();
		}
		
		/**
		 * Puts the entity into the destroyed state.
		 * 
		 * @return This entity.
		 */
		public function destroyed():Entity
		{
			state = DESTROYED;
			return this;
		}
		
		/**
		 * Puts this entity into a dirty state.
		 * 
		 * @return This instance.
		 */
		public function dirty():Entity
		{
			state = (state ^ 0xF) | DIRTY;
			return this;
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
			return storeKey;
		}
		
		/**
		 * Performs a check on the property of this entity to see if it has changed since the 
		 * last save.
		 * 
		 * @param property The property to check.
		 * @return <code>true</code> if the property has been updated.
		 */
		public function hasChanged(property:String):Boolean
		{
			return changes.hasChanged(property);
		}
		
		/**
		 * Performs a check to see if this entity is in the given state. This method uses the
		 * logical <code>&</code> operator when testing the status.
		 * 
		 * @param state The state to test against.
		 * @return <code>true</code> if the states match.
		 */
		public function isInState(value:int):Boolean
		{
			return (state & value) != 0;
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
		 * Marks the entity as being persisted.
		 * 
		 * @return This instance.
		 */
		public function persisted():Entity
		{
			state = PERSISTED;
			return this;
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
			changes.changed(property, oldValue, newValue);
			_aggregates.changed(property);
		}
		
		/**
		 * Reverts all changes made to this entity since the last save.
		 */
		public function revert():void
		{
			changes.revert();
		}
		
		/**
		 * Marks the entity as a new entity if the entity has been destroyed.
		 */
		public function revive():void
		{
			if (isDestroyed) {
				id = 0;
			}
		}
		
		/**
		 * Marks the entity as being synced with the server.
		 * 
		 * @return This instance.
		 */
		public function synced():Entity
		{
			state = ((state >> 4) << 4) | SYNCED;
			return this;
		}
		
		/**
		 * @private
		 */
		override public function toString():String
		{
			return humanize(reflect.className);
		}
		
		/**
		 * Returns the value for a given property before the entity's last save.
		 * 
		 * @param property The property to retrieve.
		 * @return The property's previous value.
		 */
		public function whatWas(property:String):*
		{
			return changes.whatWas(property);
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
		
		private var _changes:Changes = new Changes(this);
		/**
		 * @copy Changes
		 */
		public function get changes():Changes
		{
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
		
		/**
		 * <code>true</code> if this record has been synced with the server.
		 */
		public function get isSynced():Boolean
		{
			return isInState(SYNCED);
		}
		
		/**
		 * <code>true</code> if this record has been destroyed.
		 */
		public function get isDestroyed():Boolean
		{
			return isInState(DESTROYED);
		}
		
		/**
		 * <code>true</code> if this entity is dirty and needs to be persisted. An object is dirty
		 * if any of its properties have changed since its last save or if its a new record. An
		 * entity is also dirty if any association that is marked for auto-save is dirty.
		 * 
		 * @see #hasPropertyChanges
		 */
		public function get isDirty():Boolean
		{
			return isInState(DIRTY); 
		}
		
		/**
		 * <code>true</code> if this entity has any changes to its properties that need to be 
		 * persisted. This does not include auto-saved associations. To check if any associations
		 * need to be persisted, use <code>isDirty</code>.
		 * 
		 * @see #isDirty
		 */
		public function get hasPropertyChanges():Boolean
		{
			return changes.hasChanges;
		}
		
		/**
		 * <code>true</code> if this entity is a new record that needs to be persisted. By default, 
		 * an entity is considered new if its ID is 0. Sub-classes may override this implementation
		 * and provide their own.
		 */
		public function get isNew():Boolean
		{
			return isInState(INITIALIZED);
		}
		
		/**
		 * <code>true</code> if the entity is persisted in the entity's service. An entity is persisted
		 * when it hasn't been destroyed and its not a new record.
		 */
		public function get isPersisted():Boolean
		{
			return isInState(PERSISTED);
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
		
		[Bindable]
		/**
		 * The current state of the entity in its lifecycle.
		 */
		public var state:int = EMPTY;
		
		/**
		 * The store that owns this entity.
		 */
		public var store:Store;
		
		/**
		 * The global unique identifier assigned to this entity by the store.
		 */
		public var storeKey:Object;
	}
}