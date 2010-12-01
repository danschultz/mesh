package mesh
{
	import collections.HashMap;
	import collections.Set;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.utils.Proxy;
	import flash.utils.describeType;
	import flash.utils.flash_proxy;
	import flash.utils.getDefinitionByName;
	
	import mx.events.PropertyChangeEvent;
	import mx.utils.StringUtil;
	
	import operations.EmptyOperation;
	import operations.FinishedOperationEvent;
	import operations.Operation;
	
	import reflection.clazz;
	import reflection.newInstance;
	
	import validations.Validator;
	
	/**
	 * An entity.
	 * 
	 * @author Dan Schultz
	 */
	public dynamic class Entity extends Proxy implements IEventDispatcher
	{
		private static const DESCRIPTIONS:HashMap = new HashMap();
		private static const VALIDATORS:HashMap = new HashMap();
		
		private var _dispatcher:EventDispatcher;
		
		/**
		 * Constructor.
		 */
		public function Entity()
		{
			super();
			
			_dispatcher = new EventDispatcher(this);
			
			var entityClass:Class = clazz(this);
			
			// create and cache aggregates and relationships.
			if (!DESCRIPTIONS.containsKey(entityClass)) {
				DESCRIPTIONS.put(entityClass, EntityDescription.fromEntity(entityClass));
			}
			
			// create and cache the validators.
			if (!VALIDATORS.containsKey(entityClass)) {
				VALIDATORS.put(entityClass, validators());
			}
			
			addEventListener(PropertyChangeEvent.PROPERTY_CHANGE, handlePropertyChange);
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
			return entity != null && id.equals(entity.id);
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
			return id.guid;
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
		final public function isInvalid():Boolean
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
		final public function isValid():Boolean
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
		 * Removes the entity.
		 * 
		 * @return An executing operation.
		 */
		public function remove():Operation
		{
			return new EmptyOperation();
		}
		
		/**
		 * Saves the entity.
		 * 
		 * @return An executing operation.
		 */
		public function save(validate:Boolean = true):Operation
		{
			var finishedFunc:Function = function(event:FinishedOperationEvent):void
			{
				saved();
			};
			
			var operation:Operation = new EmptyOperation();
			operation.addEventListener(FinishedOperationEvent.FINISHED, finishedFunc);
			operation.execute();
			
			return operation;
		}
		
		/**
		 * Marks this entity as being persisted.
		 */
		public function saved():void
		{
			_properties.reset();
		}
		
		/**
		 * Runs the validations defined on this entity and returns the set of errors for
		 * any validations that failed. If all validations passed, this method returns an
		 * empty array.
		 *
		 * @return A set of <code>ValidationError</code>s.
		 * 
		 * @see #isInvalid()
		 * @see #isValid()
		 */
		public function validate():Array
		{
			var errors:Array = [];
			for each (var validator:Validator in VALIDATORS.grab(clazz(this))) {
				errors = errors.concat(validator.validate(this));
			}
			return errors;
		}
		
		/**
		 * Returns a set of validators defined for this entity. This method allows sub-classes
		 * to override and supply their own validators without using metadata. The default
		 * implementation of this method will return any validators that were defined in metadata.
		 * 
		 * @return A set of <code>Validator</code>s.
		 */
		protected function validators():Array
		{
			var descriptionXML:XML = describeType(this);
			var validators:Array = [];
			
			for each (var validateXML:XML in descriptionXML..metadata.(@name == "Validate")) {
				var options:Object = {};
				
				for each (var argXML:XML in validateXML..arg) {
					if (argXML.@key != "validator") {
						options[argXML.@key] = argXML.@value.toString();
					}
				}
				
				if (validateXML.parent().name() == "accessor") {
					options["property"] = validateXML.parent().@name.toString();
				}
				
				if (options.hasOwnProperty("properties")) {
					options.properties = StringUtil.trimArrayElements(options.properties, ",").split(",");
				}
				
				validators.push(newInstance(getDefinitionByName(validateXML.arg.(@key == "validator").@value) as Class, options));
			}
			
			return validators;
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
		
		private var _id:EntityID = new EntityID();
		/**
		 * An object that represents the ID for this entity.
		 */
		public function get id():EntityID
		{
			return _id;
		}
		
		/**
		 * <code>true</code> if this entity is dirty and needs to be persisted.
		 */
		public function get isDirty():Boolean
		{
			return _properties.hasChanges;
		}
		
		/**
		 * Returns the set of <code>Aggregate</code>s for this entity.
		 */
		public function get aggregates():Set
		{
			return DESCRIPTIONS.grab(clazz(this)).aggregates;
		}
		
		/**
		 * Returns the set of <code>Relationship</code>s for this entity.
		 */
		public function get relationships():Set
		{
			return DESCRIPTIONS.grab(clazz(this)).relationships;
		}
		
		private var _properties:Properties = new Properties(this);
		/**
		 * @private
		 */
		override flash_proxy function getProperty(name:*):*
		{
			if (_properties.hasOwnProperty(name)) {
				return _properties[name];
			}
			
			if (name.toString().lastIndexOf("Was") == name.toString().length-3) {
				return _properties.oldValueOf(name.toString().substr(0, name.toString().length-3));
			}
			
			for each (var aggregate:Aggregate in aggregates) {
				if (aggregate.hasMappedProperty(name)) {
					return aggregate.getValue(this, name);
				}
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
			_properties[name] = value;
			
			for each (var aggregate:Aggregate in aggregates) {
				if (aggregate.hasMappedProperty(name)) {
					aggregate.setValue(this, name, value);
					return;
				}
			}
		}
	}
}