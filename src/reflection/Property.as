package reflection
{
	import flash.utils.getDefinitionByName;
	import flash.utils.getQualifiedClassName;

	/**
	 * A class that represents a variable, getter or setter definition on a class.
	 * 
	 * @author Dan Schultz
	 */
	public class Property extends Definition
	{
		public static const ACCESSOR:int = 0;
		public static const CONSTANT:int = 1;
		public static const VARIABLE:int = 2;
		
		private static const types:Array = ["accessor", "constant", "variable"];
		
		/**
		 * @copy Definition#Definition()
		 */
		public function Property(name1:String, isStatic:Boolean, type:int, belongsTo:Definition)
		{
			super(name1, belongsTo, belongsTo.description.descendants(types[type]).(@name == name1)[0]);
			_isStatic = isStatic;
			_isConstant = isConstant;
		}
		
		private var _isConstant:Boolean;
		/**
		 * <code>true</code> if this is a variable that has been defined with
		 * <code>const</code>.
		 */
		public function get isConstant():Boolean
		{
			return _isConstant;
		}
		
		private var _isStatic:Boolean;
		/**
		 * <code>true</code> if this is a property that has been defined with 
		 * <code>static</code>.
		 */
		public function get isStatic():Boolean
		{
			return _isStatic;
		}
		
		/**
		 * The type that is defined for the property.
		 */
		public function get type():Type
		{
			return Type.reflect(getDefinitionByName(getQualifiedClassName(description.@type.toString())));
		}
	}
}