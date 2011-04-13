package mesh
{
	import flash.errors.IllegalOperationError;
	import flash.events.EventDispatcher;
	
	import mesh.associations.Association;
	import mesh.associations.AssociationDefinition;
	import mesh.associations.HasManyAssociation;
	import mesh.associations.HasManyDefinition;
	import mesh.associations.HasOneAssociation;
	import mesh.associations.HasOneDefinition;
	import mesh.core.inflection.humanize;
	import mesh.core.reflection.Type;
	import mesh.operations.Operation;
	import mesh.services.DestroyRequest;
	import mesh.services.Request;
	import mesh.services.Service;
	import mesh.validators.Errors;
	import mesh.validators.Validator;
	
	import mx.events.PropertyChangeEvent;
	
	/**
	 * An entity.
	 * 
	 * @author Dan Schultz
	 */
	public class Entity extends EventDispatcher
	{
		private var _callbacks:Callbacks = new Callbacks();
		private var _associations:Object = {};
		private var _changes:Properties = new Properties(this);
		
		/**
		 * Constructor.
		 */
		public function Entity()
		{
			super();
			
			// add necessary callbacks for find
			afterFind(markNonLazyAssociationsAsLoaded);
			afterFind(synced);
			
			// add necessary callbacks for save
			beforeSave(validate);
			afterSave(synced);
			
			// add necessary callback for destroy
			afterDestroy(destroyed);
			
			addEventListener(PropertyChangeEvent.PROPERTY_CHANGE, handlePropertyChange);
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
		
		protected function associate(property:String, definition:AssociationDefinition):*
		{
			if (!_associations.hasOwnProperty(property)) {
				_associations[property] = definition.createProxy(this);
			}
			return _associations[property];
		}
		
		protected function hasOne(property:String, clazz:Class, options:Object = null):HasOneAssociation
		{
			return associate(property, new HasOneDefinition(reflect.clazz, property, clazz, options));
		}
		
		protected function hasMany(property:String, clazz:Class, options:Object = null):HasManyAssociation
		{
			return associate(property, new HasManyDefinition(reflect.clazz, property, clazz, options));
		}
		
		/**
		 * @copy Callbacks#callback()
		 */
		public function callback(method:String):void
		{
			_callbacks.callback(method);
		}
		
		private function addCallback(method:String, block:Function):void
		{
			_callbacks.addCallback(method, block);
		}
		
		/**
		 * Reloads the attributes of this entity from the backend.
		 * 
		 * @return An executing operation.
		 */
		public function reload():Operation
		{
			return null;
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
		 * Executes an operation that will destroy this entity from the backend. If the entity also belongs 
		 * to any associations, it will be removed from those associations.
		 * 
		 * @return An executing operation.
		 */
		public function destroy():DestroyRequest
		{
			return service.destroy(this);
		}
		
		protected function beforeDestroy(block:Function):void
		{
			addCallback("beforeDestroy", block);
		}
		
		/**
		 * Adds a callback function that will be executed before a save operation. If this 
		 * function returns <code>false</code> or throws an error, the save will halt.
		 * 
		 * @param block The callback function.
		 */
		protected function beforeSave(block:Function):void
		{
			addCallback("beforeSave", block);
		}
		
		protected function afterDestroy(block:Function):void
		{
			addCallback("afterDestroy", block)
		}
		
		protected function afterFind(block:Function):void
		{
			addCallback("afterFind", block);
		}
		
		/**
		 * Adds a callback function that will be executed after a save operation has finished.
		 * 
		 * @param block The callback function.
		 */
		protected function afterSave(block:Function):void
		{
			addCallback("afterSave", block);
		}
		
		private function destroyed():void
		{
			_isDestroyed = true;
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
			_changes.changed(property, oldValue, newValue);
		}
		
		/**
		 * Reverts all changes made to this entity since the last save.
		 */
		public function revert():void
		{
			_changes.revert();
		}
		
		/**
		 * Marks the entity as a new entity if the entity has been destroyed.
		 */
		public function revive():void
		{
			if (isMarkedForRemoval) {
				_isMarkedForRemoval = false;
			}
			
			if (isDestroyed) {
				id = 0;
				_isDestroyed = false;
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
			return service.save(this);
		}
		
		private function synced():void
		{
			_changes.clear();
		}
		
		private function markNonLazyAssociationsAsLoaded():void
		{
			for each (var association:Association in _associations) {
				if (!association.definition.isLazy && !association.isLoaded) {
					association.loaded();
				}
			}
		}
		
		/**
		 * Marks the entity to be destroyed on its next save call.
		 */
		public function markForRemoval():void
		{
			_isMarkedForRemoval = true;
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
			return _changes.oldValueOf(property);
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
		
		private var _isDestroyed:Boolean;
		/**
		 * <code>true</code> if this record has been destroyed.
		 */
		public function get isDestroyed():Boolean
		{
			return _isDestroyed;
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
			return (isNew && !isMarkedForRemoval) || 
				   ((isMarkedForRemoval || hasPropertyChanges || hasDirtyAssociations) && isPersisted); 
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
			return _changes.hasChanges;
		}
		
		/**
		 * <code>true</code> if this entity contains an association marked for auto-save that is dirty.
		 */
		public function get hasDirtyAssociations():Boolean
		{
			for each (var association:Association in _associations) {
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
		
		private var _isMarkedForRemoval:Boolean;
		/**
		 * <code>true</code> if this entity will be removed on its next save call.
		 */
		public function get isMarkedForRemoval():Boolean
		{
			return _isMarkedForRemoval;
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
		
		/**
		 * The service attached to this entity.
		 */
		public function get service():Service
		{
			throw new IllegalOperationError(reflect.className + ".service is not implemented.");
		}
	}
}