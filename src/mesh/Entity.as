package mesh
{
	import collections.ISet;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.utils.Proxy;
	import flash.utils.flash_proxy;
	import flash.utils.getQualifiedClassName;
	import flash.utils.getQualifiedSuperclassName;
	import flash.utils.setTimeout;
	
	import mesh.core.inflection.humanize;
	
	import mesh.adaptors.ServiceAdaptor;
	import mesh.associations.AssociationCollection;
	import mesh.associations.AssociationProxy;
	import mesh.associations.Relationship;
	import mesh.validators.Errors;
	import mesh.validators.Validator;
	
	import mx.events.PropertyChangeEvent;
	
	import operations.Operation;
	
	import mesh.core.reflection.Property;
	import mesh.core.reflection.className;
	import mesh.core.reflection.clazz;
	import mesh.core.reflection.reflect;
	
	/**
	 * An entity.
	 * 
	 * @author Dan Schultz
	 */
	public dynamic class Entity extends Proxy implements IEventDispatcher, IPersistable
	{
		private var _dispatcher:EventDispatcher;
		private var _callbacks:Callbacks = new Callbacks();
		
		/**
		 * Constructor.
		 */
		public function Entity()
		{
			super();
			
			_dispatcher = new EventDispatcher(this);
			
			// add necessary callbacks for find
			afterFind(function(entity:Entity):void
			{
				_properties.clear();
			});
			afterFind(function(entity:Entity):void
			{
				markNonLazyAssociationsAsLoaded();
			});
			
			// add necessary callbacks for save
			afterSave(function(entity:Entity):void
			{
				_properties.clear();
			});
			
			// add necessary callback for destory
			afterDestroy(function(entity:Entity):void
			{
				_isDestroyed = true;
			});
			
			addEventListener(PropertyChangeEvent.PROPERTY_CHANGE, handlePropertyChange);
		}
		
		public function afterFind(block:Function):void
		{
			addCallback("afterFind", block);
		}
		
		public function callback(method:String):void
		{
			_callbacks.callback(method);
		}
		
		private function addCallback(method:String, block:Function):void
		{
			_callbacks.addCallback(method, block, [this]);
		}
		
		public function removeCallback(block:Function):void
		{
			_callbacks.removeCallback(block);
		}
		
		/**
		 * Returns an association proxy for the given the given property. The proxy that is
		 * returned is determined by the relationship type. For instance, if the property is
		 * a has-many relationship, a <code>HasManyAssociation</code> is returned.
		 * 
		 * @param property The property of the relationship to get the proxy for.
		 * @return An association proxy.
		 */
		public function association(property:String):AssociationProxy
		{
			if (!_associations.hasOwnProperty(property)) {
				var relationship:Relationship = descriptor.getRelationshipForProperty(property);
				if (relationship == null) {
					throw new ArgumentError("Relationship not defined for '" + property + "'");
				}
				_associations[property] = relationship.createProxy(this);
			}
			return _associations[property];
		}
		
		/**
		 * Checks if two entities are equal.  By default, two entities are equal
		 * when they are of the same type, and their ID's are the same.
		 * 
		 * @param entity The entity to check.
		 * @return <code>true</code> if the entities are equal.
		 */
		public function equals(entity:Entity):Boolean
		{
			return entity != null && 
				   (this === entity || (isPersisted && id === entity.id)) && 
				   clazz(this) == clazz(entity);
		}
		
		/**
		 * Creates an operation that when executed will destroy the entity from the backend.
		 * 
		 * @return An unexecuted operation.
		 */
		public function createDestroy():Operation
		{
			markForRemoval();
			return createSave();
		}
		
		/**
		 * Executes an operation that will destroy this entity from the backend. If the entity also belongs 
		 * to any associations, it will be removed from those associations.
		 * 
		 * @return An executing operation.
		 */
		public function destroy():Operation
		{
			var operation:Operation = createDestroy();
			setTimeout(operation.execute, Mesh.DELAY);
			return operation;
		}
		
		public function beforeDestroy(block:Function):void
		{
			addCallback("beforeDestroy", block);
		}
		
		public function afterDestroy(block:Function):void
		{
			addCallback("afterDestroy", block)
		}
		
		/**
		 * Called when the entity has been successfully destroyed from its backend service.
		 */
		protected function destroyed():void
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
			_properties.changed(property, oldValue, newValue);
		}
		
		/**
		 * Reverts all changes made to this entity since the last save.
		 */
		public function revert():void
		{
			_properties.revert();
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
		 * @inheritDoc
		 */
		public function batch(batch:SaveBatch):void
		{
			if (isMarkedForRemoval) {
				batch.destroy(this);
			} else if (isNew) {
				batch.create(this);
			} else if (hasPropertyChanges) {
				batch.update(this);
			}
			
			for each (var association:AssociationProxy in associations) {
				if (association.relationship.autoSave) {
					batch.add(association);
				}
			}
		}
		
		public function createSave():Operation
		{
			return new SaveBatch().add(this).build();
		}
		
		/**
		 * Saves the entity by executing either a create or update operation on the entity's 
		 * service.
		 * 
		 * <p>
		 * By default, save will always run the entity's validations. Clients can bypass this
		 * functionality by passing <code>false</code>. If any validation fails, save will 
		 * return <code>false</code>. Otherwise, an executed <code>Operation</code> is returned.
		 * </p>
		 * 
		 * @param validate <code>false</code> if validations should be ignored.
		 * @return An executing operation, or <code>false</code> if a validation fails.
		 */
		public function save():Operation
		{
			var operation:Operation = createSave();
			setTimeout(operation.execute, Mesh.DELAY);
			return operation;
		}
		
		/**
		 * Adds a callback function that will be executed before a save operation. If this 
		 * function returns <code>false</code> or throws an error, the save will halt.
		 * 
		 * @param callback The callback function.
		 */
		public function beforeSave(block:Function):void
		{
			addCallback("beforeSave", block);
		}
		
		/**
		 * Adds a callback function that will be executed after a save operation has finished.
		 * 
		 * @param callback
		 */
		public function afterSave(block:Function):void
		{
			addCallback("afterSave", block);
		}
		
		/**
		 * Marks this entity as being persisted.
		 */
		public function persisted():void
		{
			_properties.clear();
		}
		
		/**
		 * Marks this entity as being loaded from its backend service.
		 */
		public function found():void
		{
			callback("afterFind");
		}
		
		private function markNonLazyAssociationsAsLoaded():void
		{
			for each (var association:AssociationProxy in associations) {
				if (!association.relationship.isLazy && !association.isLoaded) {
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
		public function toString():String
		{
			return humanize(className(this));
		}
		
		public function toJSON(options:Object = null):Object
		{
			return null;
		}
		
		public function toXML(options:Object = null):XML
		{
			return null;
		}
		
		public function toVO(options:Object = null):Object
		{
			var vo:Object = new descriptor.voType();
			for each (var property:String in properties) {
				if (options == null || !options.hasOwnProperty("including") || options.including.indexOf(property) != -1) {
					if (options == null || (!options.hasOwnProperty("excluding") || options.excluding.indexOf(property) == -1)) {
						var value:Object = descriptor.getRelationshipForProperty(property) != null ? association(property) : this[property];
						if (value != null && value.hasOwnProperty("toVO")) {
							// need to pass through the options provided for this property.
							var propertyOptions:Object = {};
							
							if (value is AssociationCollection) {
								propertyOptions.type = reflect(vo).property(property).type.clazz;
							}
							
							value = value.toVO(propertyOptions);
						}
						vo[property] = value;
					}
				}
			}
			return vo;
		}
		
		public function fromVO(vo:Object, options:Object = null):void
		{
			for each (var property:Property in reflect(vo).properties) {
				var value:Object = this[property];
				if (value != null && value.hasOwnProperty("fromVO")) {
					value.fromVO(vo[property]);
				} else {
					this[property] = vo[property];
				}
			}
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
		public function was(property:String):*
		{
			return _properties.oldValueOf(property);
		}
		
		/**
		 * Returns the mapped instance of the service adaptor for the given entity.
		 * 
		 * @param entity The entity to get the service adaptor for.
		 * @return A service adaptor.
		 */
		public static function adaptorFor(entity:Object):ServiceAdaptor
		{
			return EntityDescription.describe(entity).adaptor;
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
		public function validate():Array
		{
			_errors = null;
			
			var clazz:Class = getQualifiedClassName(this) as Class;
			while (clazz is Entity) {
				var validations:Object = clazz["validator"];
				for (var property:String in validations) {
					for each (var validation:Object in validations[property]) {
						var ValidatorClass:Class = validation.validator;
						(new ValidatorClass(validation) as Validator).validate(this);
					}
				}
				clazz = getQualifiedSuperclassName(clazz) as Class;
			}
			return errors.toArray();
		}
		
		/**
		 * The adaptor defined for this entity.
		 */
		public function get adaptor():ServiceAdaptor
		{
			return descriptor.adaptor;
		}
		
		/**
		 * The set of associations that belong to this entity.
		 */
		public function get associations():Array
		{
			var result:Array = [];
			for each (var relationship:Relationship in descriptor.relationships) {
				result.push(association(relationship.property));
			}
			return result;
		}
		
		private var _descriptor:EntityDescription;
		/**
		 * The description that contains the aggregates, relationships, validators and service
		 * adaptor for this entity.
		 */
		public function get descriptor():EntityDescription
		{
			if (_descriptor == null) {
				_descriptor = EntityDescription.describe(this);
			}
			return _descriptor;
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
			return _properties.hasChanges;
		}
		
		/**
		 * <code>true</code> if this entity contains an association marked for auto-save that is dirty.
		 */
		public function get hasDirtyAssociations():Boolean
		{
			for each (var association:AssociationProxy in associations) {
				if (association.relationship.autoSave && association.isDirty) {
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
		
		/**
		 * A set of properties that are accessible on this entity. Properties include any that
		 * are defined on the entity and its sub-classes, and any properties defined within 
		 * metadata, such as <code>ComposedOf</code> or <code>HasOne</code>.
		 */
		public function get properties():ISet
		{
			return descriptor.properties;
		}
		
		/**
		 * @private
		 */
		override flash_proxy function callProperty(name:*, ...parameters):*
		{
			throw new Error("Method '" + name + "' does not exist on " + className(this) + ".");
		}
		
		private var _properties:Properties = new Properties(this);
		private var _associations:Properties = new Properties(this);
		/**
		 * @private
		 */
		override flash_proxy function getProperty(name:*):*
		{
			// check if the caller wants the association
			if (descriptor.getRelationshipForProperty(name) != null) {
				return association(name);
			}
			
			// check if the caller wants the association proxy.
			if (name.toString().indexOf("Association") > 0) {
				return association(name.toString().replace("Association", ""));
			}
			
			if (_properties.hasOwnProperty(name)) {
				return _properties[name];
			}
			
			var aggregate:Aggregate = descriptor.getAggregateForProperty(name);
			if (aggregate != null && aggregate.property != name.toString()) {
				return aggregate.getValue(this, name);
			}
			
			if (name.toString().lastIndexOf("Was") == name.toString().length-3) {
				var property:String = name.toString().substr(0, name.toString().length-3);
				
				aggregate = descriptor.getAggregateForProperty(property);
				if (aggregate != null) {
					var aggregateValue:Object = _properties.oldValueOf(aggregate.property);
					if (aggregateValue != null) {
						return aggregateValue[aggregate.getMappedProperty(property)];
					}
				}
				return was(property);
			}
			
			return undefined;
		}
		
		/**
		 * @private
		 */
		override flash_proxy function hasProperty(name:*):Boolean
		{
			return flash_proxy::getProperty(name) !== undefined;
		}
		
		/**
		 * @private
		 */
		override flash_proxy function setProperty(name:*, value:*):void
		{
			if (!properties.contains(name.toString())) {
				throw new ArgumentError(name + " not defined on " + className(this));
			}
			
			if (descriptor.getRelationshipForProperty(name) != null) {
				association(name).target = value is AssociationProxy ? value.target : value;
				return;
			}
			
			var oldValue:* = _properties[name];
			_properties[name] = value;
			
			var aggregate:Aggregate = descriptor.getAggregateForProperty(name);
			if (aggregate != null && aggregate.property != name.toString()) {
				aggregate.setValue(this, name, value);
				return;
			}
			if (aggregate != null && aggregate.isBindable && aggregate.property == name.toString()) {
				dispatchEvent(PropertyChangeEvent.createUpdateEvent(this, name.toString(), oldValue, value));
			}
		}
		
		/**
		 *  @private
		 */
		override flash_proxy function nextName(index:int):String
		{
			return _iteratingProperties[index-1];
		}
		
		private var _iteratingProperties:Array;
		private var _len:int;
		/**
		 * @private
		 */
		override flash_proxy function nextNameIndex(index:int):int
		{
			if (index == 0) {
				_iteratingProperties = properties.toArray();
				_len = _iteratingProperties.length;
			}
			return index < _len ? index+1 : 0;
		}
		
		/**
		 * @private
		 */
		override flash_proxy function nextValue(index:int):*
		{
			return this[_iteratingProperties[index-1]];
		}
		
		/**
		 * @inheritDoc
		 */
		public function addEventListener(type:String, listener:Function, useCapture:Boolean = false, priority:int = 0, useWeakReference:Boolean = false):void
		{
			_dispatcher.addEventListener(type, listener, useCapture, priority, useWeakReference);
		}
		
		/**
		 * @inheritDoc
		 */
		public function dispatchEvent(event:Event):Boolean
		{
			return _dispatcher.dispatchEvent(event);
		}
		
		/**
		 * @inheritDoc
		 */
		public function hasEventListener(type:String):Boolean
		{
			return _dispatcher.hasEventListener(type);
		}
		
		/**
		 * @inheritDoc
		 */
		public function removeEventListener(type:String, listener:Function, useCapture:Boolean = false):void
		{
			_dispatcher.removeEventListener(type, listener, useCapture);
		}
		
		/**
		 * @inheritDoc
		 */
		public function willTrigger(type:String):Boolean
		{
			return _dispatcher.willTrigger(type);
		}
	}
}