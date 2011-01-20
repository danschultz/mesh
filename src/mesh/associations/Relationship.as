package mesh.associations
{
	import flash.errors.IllegalOperationError;
	import flash.utils.Proxy;
	import flash.utils.flash_proxy;
	import flash.utils.getDefinitionByName;
	import flash.utils.getQualifiedClassName;
	
	import mesh.Entity;
	import mesh.core.inflection.camelize;
	import mesh.core.inflection.humanize;
	import mesh.core.reflection.className;
	import mesh.core.reflection.newInstance;
	
	use namespace flash_proxy;
	
	/**
	 * A relationship represents an association between two entities, where the <code>owner</code>
	 * is the host of the <code>target</code>. Take an example where you have an association
	 * where a Post contains a set of Comments. In this example, Post would be your owner and 
	 * Comment is your target.
	 * 
	 * @author Dan Schultz
	 */
	public dynamic class Relationship extends Proxy
	{
		/**
		 * Constructor.
		 * 
		 * @param owner The source of the assocation.
		 * @param property The property or method on the source that references the destination.
		 * @param target The destination of the association.
		 * @param options A set of options defined for this relationship.
		 */
		public function Relationship(owner:Class, property:String, target:Class, options:Object)
		{
			if (property == null || property.length == 0) {
				throw new ArgumentError("Missing property for '" + humanize(className(this)).toLowerCase() + "' on " + className(owner));
			}
			
			if (options.hasOwnProperty("isLazy")) {
				options.lazy = options.isLazy;
			}
			
			_owner = owner;
			_property = property;
			_target = target;
			_options = options;
		}
		
		/**
		 * Generates a new association proxy for this relationship.
		 * 
		 * @return A new association proxy.
		 */
		public function createProxy(entity:Entity):*
		{
			var associationClassName:String = getQualifiedClassName(this).replace("Relationship", "Association");
			var proxy:AssociationProxy = newInstance(getDefinitionByName(associationClassName) as Class, entity, this);
			if (proxy == null) {
				throw new IllegalOperationError("Could not find proxy for " + className(this));
			}
			return proxy;
		}
		
		/**
		 * Checks that two relationships are equal.
		 * 
		 * @param relationship The relationship to check with.
		 * @return <code>true</code> if the two are equal.
		 */
		public function equals(relationship:Relationship):Boolean
		{
			return relationship != null && 
				   owner == relationship.owner &&
				   property == relationship.property &&
				   target == relationship.target;
		}
		
		/**
		 * @private
		 */
		public function hashCode():Object
		{
			return property;
		}
		
		/**
		 * The property name for this relationship.
		 * 
		 * @return The property name.
		 */
		public function toString():String
		{
			return property;
		}
		
		private function toBoolean(obj:Object):Boolean
		{
			return obj.toString().toLowerCase() == "true";
		}
		
		/**
		 * <code>true</code> if this relationship will be saved when its owner is saved.
		 */
		public function get autoSave():Boolean
		{
			if (options.hasOwnProperty("autoSave")) {
				return toBoolean(options.autoSave);
			}
			return false;
		}
		
		/**
		 * <code>true</code> if this relationship is lazy, and its data is not loaded when
		 * the owner is loaded.
		 */
		public function get isLazy():Boolean
		{
			if (options.hasOwnProperty("lazy")) {
				return toBoolean(options.lazy);
			}
			return false;
		}
		
		private var _options:Object;
		/**
		 * A set of options that a client has configured for this relationship.
		 */
		public function get options():Object
		{
			return _options;
		}
		
		private var _owner:Class;
		/**
		 * The source entity for the association.
		 */
		public function get owner():Class
		{
			return _owner;
		}
		
		private var _property:String;
		/**
		 * The property or method on the source that references the destination.
		 */
		public function get property():String
		{
			return _property;
		}
		
		/**
		 * A list of all the properties related to this relationship that will be included
		 * on the entity.
		 */
		public function get properties():Array
		{
			return [property];
		}
		
		private var _target:Class;
		/**
		 * The destination entity for the association.
		 */
		public function get target():Class
		{
			return _target;
		}
		
		/**
		 * @inheritDoc
		 */
		override flash_proxy function getProperty(name:*):*
		{
			// supports calls like: relationship.isHasOne, or relationship.isHasMany.
			if (name.toString().indexOf("is") == 0) {
				return camelize(name.toString().replace("is", ""), false) == className(this).replace(className(Relationship), "");
			}
			
			// supports calls like: relationship.hasLazy
			if (name.toString().indexOf("has") == 0) {
				return hasProperty(camelize(name.toString().replace("has", ""), false));
			}
			
			// forward calls to options.
			return options[name];
		}
		
		/**
		 * @inheritDoc
		 */
		override flash_proxy function hasProperty(name:*):Boolean
		{
			return flash_proxy::getProperty(name) !== undefined;
		}
	}
}