package reflection
{
	import collections.HashMap;
	
	import flash.utils.describeType;
	import flash.utils.getDefinitionByName;
	import flash.utils.getQualifiedClassName;
	import flash.utils.getQualifiedSuperclassName;
	
	/**
	 * A class that represents a type definition, such as an interface or class.
	 * 
	 * @author Dan Schultz
	 */
	public class Type extends Definition
	{
		/**
		 * Constructor.
		 * 
		 * @param clazz The class to reflect.
		 */
		public function Type(classOrInstance:Object)
		{
			_clazz = classOrInstance is Class ? classOrInstance as Class : getDefinitionByName(getQualifiedClassName(classOrInstance)) as Class;
			var description:XML = describeType(classOrInstance);
			var parentClassName:String = getQualifiedSuperclassName(classOrInstance);
			var parent:Type = parentClassName != null ? new Type(getDefinitionByName(parentClassName) as Class) : null;
			super(description, parent);
		}
		
		/**
		 * Caches a reflection object for the given class or object.
		 * 
		 * @param obj The object or class to reflect.
		 * @return A reflection object.
		 */
		public static function reflect(obj:Object):Type
		{
			var c:Class = obj is Class ? obj as Class : clazz(obj);
			var key:String = "__reflection_for_" + ((obj is Class) ? "class" : "instance");
			if (c[key] == null) {
				c[key] = new Type(obj);
			}
			return c[key];
		}
		
		/**
		 * Checks if the given <code>Type</code> or <code>Class</code> belongs to the inheritance
		 * chain of this type.
		 * 
		 * @param typeOrClass An instance of <code>Type</code> or <code>Class</code>.
		 * @return <code>true</code> if the type belongs to the inheritance chain of <code>typeOrClass</code>.
		 */
		public function isA(typeOrClass:Object):Boolean
		{
			var clazz:Class = typeOrClass is Class ? typeOrClass as Class : Type( typeOrClass ).clazz;
			
			if (clazz == _clazz) {
				return true;
			}
			
			for each (var extension:Type in parents.concat(implementing)) {
				if (extension.isA(typeOrClass)) {
					return true;
				}
			}
			
			return false;
		}
		
		/**
		 * Returns the property belonging to this type with the given name.
		 * 
		 * @param name The name of the property to retrieve.
		 * @return A property.
		 */
		public function property(name:String):Property
		{
			return cachedProperties.grab(name);
		}
		
		/**
		 * Returns the method belonging to this type with the given name.
		 * 
		 * @param name The name of the method to retrieve.
		 * @return A method.
		 */
		public function method(name:String):Method
		{
			return cachedMethods.grab(name);
		}
		
		private var _allMetadata:Array;
		/**
		 * Returns all metadata that is associated with this type, including metadata that is
		 * defined on properties and methods of the class.
		 */
		public function get allMetadata():Array
		{
			if (_allMetadata == null) {
				_allMetadata = metadata;
				
				for each (var definition:Definition in properties.concat(methods)) {
					_allMetadata = _allMetadata.concat(definition.metadata);
				}
			}
			return _allMetadata;
		}
		
		private var _properties:HashMap;
		private function get cachedProperties():HashMap
		{
			if (_properties == null) {
				_properties = new HashMap();
				
				for each (var accessorXML:XML in description..accessor) {
					if (accessorXML.@declaredBy.toString() == name) {
						_properties.put(accessorXML.@name.toString(), new Property(accessorXML, this));
					}
				}
				
				for each (var constantXML:XML in description..constant) {
					_properties.put(constantXML.@name.toString(), new Property(constantXML, this));
				}
				
				for each (var variableXML:XML in description..variable) {
					_properties.put(variableXML.@name.toString(), new Property(variableXML, this));
				}
				
				for each (var parent:Type in parents) {
					for each (var property:Property in parent.properties) {
						if (!property.isStatic) {
							_properties.put(property.name, property);
						}
					}
				}
			}
			return _properties;
		}
		
		/**
		 * A list of property definitions that represent the variables, getters and setters that
		 * are defined on the type.
		 */
		public function get properties():Array
		{
			return cachedProperties.values();
		}
		
		private var _methods:HashMap;
		private function get cachedMethods():HashMap
		{
			if (_methods == null) {
				_methods = new HashMap();
				
				for each (var methodXML:XML in description..method) {
					if (methodXML.@declaredBy.toString() == name) {
						_methods.put(methodXML.@name.toString(), new Method(methodXML, this));
					}
				}
				
				for each (var parent:Type in parents) {
					for each (var method:Method in parent.methods) {
						if (!method.isStatic) {
							_methods.put(method.name, method);
						}
					}
				}
			}
			return _methods;
		}
		
		/**
		 * A list of method definitions that represent the functions that are defined on the type.
		 */
		public function get methods():Array
		{
			return cachedMethods.values();
		}
		
		private var _clazz:Class;
		/**
		 * The class that this object is reflecting.
		 */
		public function get clazz():Class
		{
			return _clazz;
		}
		
		private var _className:String;
		/**
		 * The name of the class that this object is reflecting.
		 * 
		 * <p>
		 * <strong>Example:</strong> <em>DisplayObject</em>
		 * </p>
		 */
		public function get className():String
		{
			if (_className == null) {
				_className = name.split("::").pop();
			}
			return _className;
		}
		
		private var _implementing:Array;
		/**
		 * A list of reflections for each interface that this class is implementing.
		 */
		public function get implementing():Array
		{
			if (_implementing == null) {
				_implementing = [];
				
				for each (var implementsXML:XML in description..implementsInterface) {
					_implementing.push(new Type(getDefinitionByName(implementsXML.@type.toString()) as Class));
				}
				
				for each (var parent:Type in parents) {
					_implementing = _implementing.concat(parent.implementing);
				}
			}
			return _implementing.concat();
		}
		
		/**
		 * <code>true</code> if the class for this reflection is extending another class.
		 */
		public function get hasParent():Boolean
		{
			return parent != null;
		}
		
		/**
		 * The reflection for the class that this class is extending from.
		 */
		public function get parent():Type
		{
			return belongsTo as Type;
		}
		
		private var _parents:Array;
		/**
		 * A list of reflections for each class that this class is extending from. The immediate
		 * parent will be at index 0, where as Object will be at index <code>length-1</code>.
		 */
		public function get parents():Array
		{
			if (_parents == null) {
				_parents = [];
				var p:Type = this;
				while (p.hasParent) {
					_parents.push(p.parent);
					p = p.parent;
				}
			}
			return _parents.concat();
		}
		
		private var _packageName:String;
		/**
		 * The name of the package for the class that this object is reflecting.
		 * 
		 * <p>
		 * <strong>Example:</strong> <em>flash.display</em>
		 * </p>
		 */
		public function get packageName():String
		{
			if (_packageName == null) {
				_packageName = name.indexOf("::") != -1 ? name.split("::").shift() : "";
			}
			return _packageName;
		}
	}
}

