package mesh
{
	import collections.HashMap;
	import collections.HashSet;
	import collections.Set;
	
	import flash.errors.IllegalOperationError;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.utils.Proxy;
	import flash.utils.describeType;
	import flash.utils.flash_proxy;
	import flash.utils.getDefinitionByName;
	import flash.utils.setTimeout;
	
	import inflections.humanize;
	import inflections.pluralize;
	
	import mesh.adaptors.ServiceAdaptor;
	
	import mx.events.PropertyChangeEvent;
	import mx.utils.StringUtil;
	
	import operations.EmptyOperation;
	import operations.FinishedOperationEvent;
	import operations.Operation;
	import operations.ParallelOperation;
	
	import reflection.className;
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
		private static const AGGREGATES:HashMap = new HashMap();
		private static const ADAPTORS:HashMap = new HashMap();
		private static const RELATIONSHIPS:HashMap = new HashMap();
		private static const VALIDATORS:HashMap = new HashMap();
		private static const TRANSFER_OBJECTS:HashMap = new HashMap();
		private static const PROPERTIES:HashMap = new HashMap();
		
		private static const EXECUTION_DELAY:int = 50;
		
		private var _dispatcher:EventDispatcher;
		
		/**
		 * Constructor.
		 */
		public function Entity()
		{
			super();
			
			_dispatcher = new EventDispatcher(this);
			
			var entityClass:Class = clazz(this);
			
			// create and cache the aggregates.
			if (!AGGREGATES.containsKey(entityClass)) {
				var entityAggregates:HashMap = new HashMap();
				for each (var aggregate:Aggregate in aggregates()) {
					for each (var mapping:String in aggregate.mappings) {
						entityAggregates.put(mapping, aggregate);
					}
				}
				AGGREGATES.put(entityClass, entityAggregates);
			}
			
			// create and cache the relationships.
			if (!RELATIONSHIPS.containsKey(entityClass)) {
				RELATIONSHIPS.put(entityClass, new HashMap());
				relationships();
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
			return entity != null && 
				   ((isPersisted && id === entity.id) || this === entity) && 
				   clazz(this) == clazz(entity);
		}
		
		/**
		 * Removes the entity.
		 * 
		 * @param execute <code>false</code> if the operation should be returned without being
		 * 	executed.
		 * @return An executing operation.
		 */
		public function destroy(execute:Boolean = true):Operation
		{
			var operation:Operation = adaptorFor(this).destroy(this);
			operation.addEventListener(FinishedOperationEvent.FINISHED, function(event:FinishedOperationEvent):void
			{
				if (event.successful) {
					_isDestroyed = true;
				}
			});
			
			if (execute) {
				setTimeout(operation.execute, EXECUTION_DELAY);
			}
			
			return operation;
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
			return runValidations().length == 0;
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
			
			for each (var property:String in relationshipsForEntity(this).keys()) {
				if (hasOwnProperty(property) && this[property] != null) {
					this[property].revert();
				}
			}
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
		 * @param execute <code>false</code> if the operation should be returned without being
		 * 	executed.
		 * @return An executing operation, or <code>false</code> if a validation fails.
		 */
		public function save(validate:Boolean = true, execute:Boolean = true):Operation
		{
			var operation:Operation = hasPropertyChanges ? (isNew ? adaptorFor(this).create(this) : adaptorFor(this).update(this)) : new EmptyOperation();
			operation.addEventListener(FinishedOperationEvent.FINISHED, function(event:FinishedOperationEvent):void
			{
				if (event.successful) {
					saved();
				}
			});
			
			var relationshipOperations:Vector.<Operation> = new Vector.<Operation>();
			for each (var property:String in relationshipsForEntity(this).keys()) {
				var association:AssociationProxy = this[property];
				if (association != null) {
					relationshipOperations.push(association.save(true, false));
				}
			}
			operation = operation.then(new ParallelOperation(relationshipOperations));
			
			if (execute) {
				setTimeout(operation.execute, EXECUTION_DELAY);
			}
			
			return operation;
		}
		
		/**
		 * Marks this entity as being persisted.
		 */
		public function saved():void
		{
			_properties.clear();
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
		public function translateTo():Object
		{
			return null;
		}
		
		/**
		 * Returns the mapped instance of the service adaptor for the given entity.
		 * 
		 * @param entity The entity to get the service adaptor for.
		 * @return A service adaptor.
		 */
		public static function adaptorFor(entity:Object):ServiceAdaptor
		{
			if (!(entity is Class)) {
				entity = clazz(entity);
			}
			
			if (!ADAPTORS.containsKey(entity)) {
				var instance:Entity = Entity( newInstance(entity as Class) );
				ADAPTORS.put(entity, instance.adaptor());
			}
			
			return ADAPTORS.grab(entity) as ServiceAdaptor;
		}
		
		/**
		 * Called when the entity is initialized for the first time to generate the service adaptor 
		 * for the these types of entities. By default, this method will return a service adaptor 
		 * that was defined in the entity's metadata. If a service adaptor is difficult to express
		 * in metadata, sub-classes may choose to override this method and construct their own.
		 * 
		 * @return A service adaptor.
		 */
		public function adaptor():ServiceAdaptor
		{
			for each (var adaptorXML:XML in describeType(this)..metadata.(@name == "ServiceAdaptor")) {
				var options:Object = {};
				
				for each (var argXML:XML in adaptorXML..arg) {
					options[argXML.@key] = argXML.@value.toString();
				}
				
				return ServiceAdaptor( newInstance(getDefinitionByName(adaptorXML.arg.(@key == "type").@value) as Class, clazz(this), options) );
			}
			throw new IllegalOperationError(humanize(className(ServiceAdaptor)) + " not found for " + className(this));
		}
		
		/**
		 * Returns a mapping of aggregates for the given entity, where the key is the aggregate's
		 * property and the value is the aggregate.
		 * 
		 * @param entity The entity to get the aggregates for.
		 * @return A mapping of <code>Aggregate</code>s.
		 */
		protected static function aggregatesForEntity(entity:Entity):HashMap
		{
			return AGGREGATES.grab(clazz(entity)) as HashMap;
		}
		
		/**
		 * Returns a set of aggregates defined for this entity. This method allows sub-classes
		 * to override and supply their own aggregates without using metadata. The default
		 * implementation of this method will return any aggregates that were defined in metadata.
		 * 
		 * @return A set of <code>Aggregate</code>s.
		 */
		protected function aggregates():Array
		{
			var aggregates:Array = [];
			
			for each (var composedOfXML:XML in describeType(this)..metadata.(@name == "ComposedOf")) {
				var property:XMLList = composedOfXML.arg.(@key == "property");
				var type:XMLList = composedOfXML.arg.(@key == "type");
				var prefix:XMLList = composedOfXML.arg.(@key == "prefix");
				var mapping:XMLList = composedOfXML.arg.(@key == "mapping");
				
				var options:Object = {};
				options.prefix = prefix.@value.toString();
				options.mapping = StringUtil.trimArrayElements(mapping.@value.toString(), ",").split(",");
				
				aggregates.push( new Aggregate(clazz(this), property.length() > 0 ? property.@value : composedOfXML.parent().@name, getDefinitionByName(type.length() > 0 ? type.@value : composedOfXML.parent().@type) as Class, options) );
			}
			
			return aggregates;
		}
		
		/**
		 * Returns the set of properties that are accessible on the given entity. Properties 
		 * include any that are defined on the entity and its sub-classes, and any properties 
		 * defined within metadata, such as <code>ComposedOf</code> or <code>HasOne</code>.
		 * 
		 * @param entity The entity to get the properties for.
		 * @return A set of properties.
		 */
		public static function propertiesFor(entity:Object):Set
		{
			if (!(entity is Class)) {
				entity = clazz(entity);
			}
			
			if (!PROPERTIES.containsKey(entity)) {
				var instance:Entity = Entity( newInstance(entity as Class) );
				PROPERTIES.put(entity, instance.properties);
			}
			
			return PROPERTIES.grab(entity) as Set;
		}
		
		/**
		 * A set of properties that are accessible on this entity. Properties include any that
		 * are defined on the entity and its sub-classes, and any properties defined within 
		 * metadata, such as <code>ComposedOf</code> or <code>HasOne</code>.
		 */
		public function get properties():Set
		{
			var properties:HashSet = new HashSet();
			
			for each (var accessorXML:XML in describeType(this)..accessor) {
				properties.add(accessorXML.@name);
			}
			
			properties.addAll(aggregatesForEntity(this).keys());
			properties.addAll(relationshipsForEntity(this).keys());
			
			return properties;
		}
		
		/**
		 * Returns a mapping of relationships for the given entity, where the key is the relationship's
		 * property and the value is the relationship.
		 * 
		 * @param entity The entity to get the relationships for.
		 * @return A mapping of <code>Relationship</code>s.
		 */
		public static function relationshipsForEntity(entity:Entity):HashMap
		{
			return RELATIONSHIPS.grab(clazz(entity)) as HashMap;
		}
		
		/**
		 * Invoked when the relationships are requested for an entity, but have not been cached
		 * yet. By default, this method will parse any relationship metadata defined in the 
		 * entity. Sub-classes can override this method and call the <code>hasMany()</code>
		 * and <code>hasOne()</code> methods.
		 * 
		 * @see #hasOne()
		 * @see #hasMany()
		 */
		protected function relationships():void
		{
			for each (var relationshipXML:XML in describeType(this)..metadata.(@name == "HasOne" || @name == "HasMany")) {
				var kind:String = relationshipXML.@name;
				var options:Object = {};
				
				for each (var argXML:XML in relationshipXML..arg) {
					options[argXML.@key] = argXML.@value.toString();
				}
				
				if (!options.hasOwnProperty("type")) {
					options.type = relationshipXML.parent().@type;
				}
				options.type = getDefinitionByName(options.type) as Class;
				
				// try to grab the property auto-magically.
				if (!options.hasOwnProperty("property")) {
					// first try to see if there's an accessor we can use.
					if (relationshipXML.parent().name() == "accessor") {
						options.property = relationshipXML.parent().@name;
					}
					// pluralize the entity type if we're a has many.
					else if (kind == "HasMany") {
						var pluralizedClassName:String = pluralize(className(options.type));
						options.property = pluralizedClassName.substr(0, 1).toLowerCase() + pluralizedClassName.substr(1);
					}
				}
				
				this[kind.substr(0, 1).toLowerCase() + kind.substr(1)](options.type, options.property, options);
			}
			
		}
		
		/**
		 * Adds a one-to-one relationship for this entity.
		 * 
		 * @param target The target entity class.
		 * @param property The property mapping the relationship.
		 * @param options Any options for the relationship.
		 * 
		 * @see #relationships()
		 * @see #hasMany()
		 */
		protected function hasOne(target:Class, property:String, options:Object = null):void
		{
			relationshipsForEntity(this).put(property, new HasOneRelationship(clazz(this), property, target, options));
		}
		
		/**
		 * Adds a one-to-many relationship for this entity.
		 * 
		 * @param target The target entity class.
		 * @param property The property mapping the relationship.
		 * @param options Any options for the relationship.
		 * 
		 * @see #relationships()
		 * @see #hasOne()
		 */
		protected function hasMany(target:Class, property:String, options:Object = null):void
		{
			relationshipsForEntity(this).put(property, new HasManyRelationship(clazz(this), property, target, options));
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
		public function runValidations():Array
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
		
		private var _isDestroyed:Boolean;
		/**
		 * <code>true</code> if this record has been destroyed.
		 */
		public function get isDestroyed():Boolean
		{
			return _isDestroyed;
		}
		
		/**
		 * <code>true</code> if this entity is either a new record or contains any property changes.
		 * This does not check to see if its associations are dirty.
		 * 
		 * @see #isDirty
		 * @see #hasDirtyAssociations
		 */
		public function get hasPropertyChanges():Boolean
		{
			return isNew || _properties.hasChanges;
		}
		
		/**
		 * <code>true</code> if this entity contains any associations that are dirty.
		 * 
		 * @see #isDirty
		 * @see #hasPropertyChanges
		 */
		public function get hasDirtyAssociations():Boolean
		{
			// more in depth check on the entity's relationships.
			for each (var property:String in relationshipsForEntity(this).keys()) {
				if (this[property] != null && AssociationProxy( this[property] ).isDirty) {
					return true;
				}
			}
			return false;
		}
		
		/**
		 * <code>true</code> if this entity is dirty and needs to be persisted. An object is dirty
		 * if any of its properties have changed since its last save or if its a new record. An
		 * entity is also dirty if any of its relationships are dirty.
		 */
		public function get isDirty():Boolean
		{
			return hasPropertyChanges || hasDirtyAssociations;
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
		
		private var _properties:Properties = new Properties(this);
		private var _relationships:Properties = new Properties(this);
		/**
		 * @private
		 */
		override flash_proxy function getProperty(name:*):*
		{
			var relationship:Relationship = relationshipsForEntity(this).grab(name.toString()) as Relationship;
			if (relationship != null) {
				if (!_relationships.hasOwnProperty(relationship.property)) {
					_relationships.changed(relationship.property, undefined, relationship.createProxy(this));
				}
			}
			
			if (_relationships.hasOwnProperty(name)) {
				return _relationships[name];
			}
			
			if (_properties.hasOwnProperty(name)) {
				return _properties[name];
			}
			
			if (name.toString().lastIndexOf("Was") == name.toString().length-3) {
				return _properties.oldValueOf(name.toString().substr(0, name.toString().length-3));
			}
			
			var aggregate:Aggregate = aggregatesForEntity(this).grab(name.toString()) as Aggregate;
			if (aggregate != null) {
				return aggregate.getValue(this, name);
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
			var relationship:Relationship = relationshipsForEntity(this).grab(name.toString()) as Relationship;
			if (relationship != null) {
				return;
			}
			
			_properties[name] = value;
			
			var aggregate:Aggregate = aggregatesForEntity(this).grab(name.toString()) as Aggregate;
			if (aggregate != null) {
				aggregate.setValue(this, name, value);
				return;
			}
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
