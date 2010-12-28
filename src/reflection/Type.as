package reflection
{
	import flash.utils.describeType;
	import flash.utils.getDefinitionByName;
	import flash.utils.getQualifiedSuperclassName;
	
	import functions.closure;
	
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
		public function Type(clazz:Class)
		{
			_clazz = clazz;
			var description:XML = describeType(clazz);
			var parent:Type = clazz != Object ? new Type(getDefinitionByName(getQualifiedSuperclassName(clazz)) as Class) : null;
			super(description.@name.toString(), parent, description);
		}
		
		public static function reflect(obj:Object):Type
		{
			var clazz:Class = obj is Class ? obj as Class : clazz(obj);
			if (clazz["__reflection"] == null) {
				clazz["__reflection"] = new Type(clazz);
			}
			return clazz["__reflection"];
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
		
		private var _properties:Array;
		/**
		 * A list of property definitions that represent the variables, getters and setters that
		 * are defined on the type.
		 */
		public function get properties():Array
		{
			if (_properties == null) {
				_properties = [];
				
				for each (var accessorXML:XML in description..accessor) {
					if (accessorXML.@declaredBy.toString() == name) {
						_properties.push(new Property(accessorXML.@name.toString(), accessorXML.parent().name() == "type", Property.ACCESSOR, this));
					}
				}
				
				for each (var constantXML:XML in description..constant) {
					_properties.push(new Property(constantXML.@name.toString(), constantXML.parent().name() == "type", Property.CONSTANT, this));
				}
				
				for each (var variableXML:XML in description..variable) {
					_properties.push(new Property(variableXML.@name.toString(), variableXML.parent().name() == "type", Property.VARIABLE, this));
				}
				
				for each (var parent:Type in parents) {
					_properties = _properties.concat(parent.properties.filter(closure(function(p:Property):Boolean
					{
						return !p.isStatic;
					})));
				}
			}
			return _properties.concat();
		}
		
		private var _methods:Array;
		/**
		 * A list of method definitions that represent the functions that are defined on the type.
		 */
		public function get methods():Array
		{
			if (_methods == null) {
				_methods = [];
				
				for each (var methodXML:XML in description..method.(@declaredBy == name)) {
					if (methodXML.@declaredBy.toString() == name) {
						_properties.push(new Method(methodXML.@name.toString(), methodXML.parent().name() == "type", this));
					}
				}
				
				for each (var parent:Type in parents) {
					_methods = _methods.concat(parent.methods.filter(closure(function(m:Method):Boolean
					{
						return !m.isStatic;
					})));
				}
			}

			return _methods.concat();
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
				
				for each (var implementsXML:XML in description..implementsInterface.(@declaredBy == name)) {
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
			return _clazz != Object;
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