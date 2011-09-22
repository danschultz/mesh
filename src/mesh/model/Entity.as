package mesh.model
{
	import com.brokenfunction.json.decodeJson;
	import com.brokenfunction.json.encodeJson;
	
	import flash.errors.IllegalOperationError;
	import flash.events.EventDispatcher;
	
	import mesh.core.inflection.humanize;
	import mesh.core.object.copy;
	import mesh.core.reflection.Type;
	import mesh.core.state.StateEvent;
	import mesh.model.associations.Association;
	import mesh.model.associations.HasManyAssociation;
	import mesh.model.associations.HasOneAssociation;
	import mesh.model.serialization.Serializer;
	import mesh.model.source.SourceFault;
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
			
			_status = new EntityStatus();
			_status.addEventListener(StateEvent.ENTER, function(event:StateEvent):void
			{
				if (status.isPersisted) {
					changes.clear();
				}
				dispatchEvent(event.clone());
			});
			
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
			_associations.map(property, new HasManyAssociation(this, property, options));
		}
		
		/**
		 * Marks this entity as destroyed and dirty.
		 * 
		 * @return This instance.
		 */
		public function destroy():Entity
		{
			status.destroy();
			return this;
		}
		
		private var _fault:SourceFault;
		/**
		 * Puts the entity into an errored lifecycle state. This state signifies that an error 
		 * occurred after a load or commit.
		 */
		public function failed(fault:SourceFault):void
		{
			_fault = fault;
			status.failed();
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
			return obj != null && (this === obj || (obj is Entity && status.isPersisted && id === obj.id));
		}
		
		/**
		 * Copies the values from an object to this entity.
		 * 
		 * @param object The object to copy from.
		 */
		public function fromObject(object:Object):void
		{
			copy(object, this);
		}
		
		/**
		 * Decodes a JSON string and copies the result to this entity.
		 * 
		 * @param json A JSON string.
		 */
		public function fromJSON(json:String):void
		{
			fromObject(decodeJson(json));
		}
		
		/**
		 * Copies the values from a value object to this entity.
		 * 
		 * @param vo The object to copy from.
		 */
		public function fromVO(vo:Object):void
		{
			
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
		 * Called by the data source when the entity has loaded. This method marks the entity as 
		 * synced and goes through each non-lazy association marking it as loaded.
		 */
		public function loaded():void
		{
			for each (var association:Association in associations) {
				if (!association.isLazy) {
					association.loaded();
				}
			}
			
			synced();
		}
		
		private static const IGNORED_PROPERTY_CHANGES:Object = {id:true};
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
			if (!IGNORED_PROPERTY_CHANGES.hasOwnProperty(property) && !associations.isAssociation(property))
			{
				changes.changed(property, oldValue, newValue);
				_aggregates.changed(property);
				status.dirty();
			}
		}
		
		/**
		 * Reverts all changes made to this entity since the last save.
		 */
		public function revert():void
		{
			changes.revert();
		}
		
		private function initializeAssociations():void
		{
			for each (var association:Association in associations) {
				association.initialize();
			}
		}
		
		/**
		 * Returns a hash of the serialized properties of this entity.
		 * 
		 * @param options An options hash to configure the serialization.
		 * @return A serialized hash.
		 */
		public function serialize(options:Object = null):Object
		{
			options = options == null ? serializableOptions : options;
			options.exclude = options.exclude is Array ? options.exclude : [];
			
			if (options.exclude.indexOf("storeKey") == -1) {
				options.exclude.push("storeKey");
			}
			
			return new Serializer(this, options).serialize();
		}
		
		/**
		 * Marks the entity as being synced with the server.
		 * 
		 * @return This instance.
		 */
		public function synced():Entity
		{
			status.synced();
			return this;
		}
		
		/**
		 * Returns an AS3 <code>Object</code> that contains the values of the serialized properties
		 * on this entity.
		 * 
		 * @return An object.
		 */
		public function toObject(options:Object = null):Object
		{
			return serialize(options);
		}
		
		/**
		 * Returns a JSON encoded string from this entity.
		 * 
		 * @return A JSON encoded string.
		 */
		public function toJSON(options:Object = null):String
		{
			return encodeJson(serialize(options));
		}
		
		/**
		 * Returns a value object that contains the values of this entity.
		 * 
		 * @param options Any options to configure the serialization.
		 * @return A new value object.
		 */
		public function toVO(options:Object = null):*
		{
			return null;
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
		[Bindable]
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
		 * The default options to use when <code>serialize()</code> is called. By default, this property is 
		 * <code>null</code> and falls back to the <code>Serializer</code>s default behavior. Sub-classes may 
		 * override this and supply their own default options.
		 * 
		 * @copy mesh.model.serialization.Serializer
		 * @see mesh.model.serialization.Serializer 
		 */
		protected function get serializableOptions():Object
		{
			return {};
		}
		
		private var _status:EntityStatus;
		/**
		 * The current state of the entity in its lifecycle.
		 */
		public function get status():EntityStatus
		{
			return _status;
		}
		
		private var _store:Store;
		[Transient]
		/**
		 * The store that owns this entity.
		 */
		public function get store():Store
		{
			return _store;
		}
		public function set store(value:Store):void
		{
			if (store != null && value != null) {
				throw new IllegalOperationError("Cannot reassign an entity's store.");
			}
			
			_store = value;
			initializeAssociations();
		}
		
		private var _storeKey:Object;
		[Transient]
		/**
		 * The global unique identifier assigned to this entity by the store.
		 */
		public function get storeKey():Object
		{
			return _storeKey;
		}
		public function set storeKey(value:Object):void
		{
			if (storeKey != null) {
				throw new IllegalOperationError("Cannot reassign an entity's store key.");
			}
			_storeKey = value;
		}
		
		/**
		 * The type of value object to use when turning the entity into a value object. This property must
		 * be overridden by sub-classes.
		 */
		protected function get valueObjectType():Class
		{
			throw new IllegalOperationError(reflect.name + ".valueObjectType is not implemented.");
		}
	}
}
