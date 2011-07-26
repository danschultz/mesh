package mesh.model
{
	import flash.events.EventDispatcher;
	import flash.utils.flash_proxy;
	
	import mesh.Mesh;
	import mesh.core.inflection.humanize;
	import mesh.core.object.copy;
	import mesh.core.reflection.Type;
	import mesh.model.associations.Association;
	import mesh.model.associations.HasManyAssociation;
	import mesh.model.associations.HasManyDefinition;
	import mesh.model.associations.HasOneAssociation;
	import mesh.model.associations.HasOneDefinition;
	import mesh.model.validators.Errors;
	import mesh.model.validators.Validator;
	import mesh.services.Request;
	
	import mx.events.PropertyChangeEvent;
	
	use namespace flash_proxy;
	
	[Exclude(kind="method", name="addObserver")]
	[Exclude(kind="method", name="removeObserver")]
	
	/**
	 * An entity.
	 * 
	 * @author Dan Schultz
	 */
	public class Entity extends EventDispatcher
	{
		/**
		 * The generic lifecycle state for when the entity has been loaded.
		 */
		public static const READY:int = 0x0100;
		
		/**
		 * The generic lifecycle state for when the entity is communicating with the
		 * data source.
		 */
		public static const BUSY:int = 0x0200;
		
		/**
		 * The generic lifecycle state for when the entity has been destroyed.
		 */
		public static const DESTROYED:int = 0x0300;
		
		/**
		 * The generic lifecycle state for when there are no changes to be committed.
		 */
		public static const CLEAN:int = 0x0001;
		
		/**
		 * The generic lifecycle state for when there are changes to be committed.
		 */
		public static const DIRTY:int = 0x0002;
		
		/**
		 * The generic lifecycle state for when there's an error after a commit.
		 */
		public static const ERROR:int = 0x0003;
		
		private var _observers:Callbacks = new Callbacks();
		private var _associations:Object = {};
		private var _aggregates:Aggregates = new Aggregates(this);
		
		/**
		 * Constructor.
		 */
		public function Entity(values:Object = null)
		{
			super();
			copy(values, this);
			addEventListener(PropertyChangeEvent.PROPERTY_CHANGE, handlePropertyChange);
		}
		
		/**
		 * @private
		 * 
		 * Not sure how observers are going to play out yet.
		 */
		public function addObserver(method:String, block:Function):void
		{
			_observers.addCallback(method, block);
		}
		
		/**
		 * @private
		 * 
		 * Not sure how observers are going to play out yet.
		 */
		public function removeObserver(method:String, block:Function):void
		{
			_observers.removeCallback(method, block);
		}
		
		protected function aggregate(property:String, type:Class, mappings:Array):void
		{
			_aggregates.add(property, type, mappings);
		}
		
		/**
		 * Returns an association proxy for the given the given property. The proxy that is
		 * returned is determined by the relationship type. For instance, if the property is
		 * a has-many relationship, a <code>HasManyAssociation</code> is returned.
		 * 
		 * @param property The property of the relationship to get the proxy for.
		 * @return An association proxy.
		 */
		protected function association(property:String):*
		{
			if (!_associations.hasOwnProperty(property)) {
				throw new ArgumentError("Undefined association on property '" + property + "'");
			}
			return _associations[property];
		}
		
		protected function associate(property:String, association:Association):*
		{
			if (!_associations.hasOwnProperty(property)) {
				_associations[property] = association;
			}
			return _associations[property];
		}
		
		protected function hasOne(property:String, clazz:Class, options:Object = null):HasOneAssociation
		{
			if (!_associations.hasOwnProperty(property)) {
				_associations[property] = new HasOneDefinition(reflect.clazz, property, clazz, options).createProxy(this);
			}
			return _associations[property];
		}
		
		protected function hasMany(property:String, clazz:Class, options:Object = null):HasManyAssociation
		{
			if (!_associations.hasOwnProperty(property)) {
				_associations[property] = new HasManyDefinition(reflect.clazz, property, clazz, options).createProxy(this);
			}
			return _associations[property];
		}
		
		/**
		 * Returns a request that will reload the attributes of this entity when executed.
		 * 
		 * @return An unexecuted request.
		 */
		public function reload():Request
		{
			var request:Request = Mesh.service(reflect.clazz).find(id);
			request.addHandler({
				success:function():void
				{
					translateFrom(request.translateTo());
				}
			});
			return request;
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
		 * Puts the entity into the destroyed state.
		 */
		public function destroy():void
		{
			state = DESTROYED | DIRTY;
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
		 * Saves the entity by executing either a create or update operation on the entity's 
		 * service.
		 * 
		 * @return An executing operation, or <code>false</code> if a validation fails.
		 */
		public function save():Request
		{
			return Mesh.service(reflect.clazz).save([this]);
		}
		
		private function markNonLazyAssociationsAsLoaded():void
		{
			for each (var association:Association in associations) {
				if (!association.definition.isLazy && !association.isLoaded) {
					association.callback("afterLoad");
				}
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
		 * Copies the translated values on the given object to this entity. This method is useful for
		 * copying the values of a transfer object or XML into the entity for service calls.
		 * 
		 * @param object The object to translate and copy.
		 */
		public function translateFrom(object:Object):void
		{
			
		}
		
		/**
		 * Creates a new translation object, which is useful for creating transfer objects or XML for
		 * service calls.
		 * 
		 * @return A new translation object.
		 */
		public function translateTo():*
		{
			return null;
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
		 * A hash of the associations for this entity, where the key represents the association's
		 * property, and the value is the <code>Association</code>.
		 */
		public function get associations():Object
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
			if (value == 0) {
				value = undefined;
			}
			if (value == "") {
				value = undefined;
			}
			if (value == null) {
				value = undefined;
			}
			_id = value;
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
		 * <code>true</code> if this entity contains an association marked for auto-save that is dirty.
		 */
		public function get hasDirtyAssociations():Boolean
		{
			for each (var association:Association in associations) {
				if (association.definition.autoSave && association.isDirty) {
					return true;
				}
			}
			return false;
		}
		
		/**
		 * <code>true</code> if this entity is a new record that needs to be persisted. By default, 
		 * an entity is considered new if its ID is 0. Sub-classes may override this implementation
		 * and provide their own.
		 */
		public function get isNew():Boolean
		{
			return id === undefined;
		}
		
		/**
		 * <code>true</code> if the entity is persisted in the entity's service. An entity is persisted
		 * when it hasn't been destroyed and its not a new record.
		 */
		public function get isPersisted():Boolean
		{
			return !isNew && !isDestroyed;
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
		public var state:int;
		
		/**
		 * The global unique identifier assigned to this entity by the store.
		 */
		public var storeKey:Object;
	}
}