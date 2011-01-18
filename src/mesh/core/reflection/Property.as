package mesh.core.reflection
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
		/**
		 * @copy Definition#Definition()
		 */
		public function Property(description:XML, belongsTo:Definition)
		{
			super(description, belongsTo);
		}
		
		/**
		 * <code>true</code> if this is a variable that has been defined with
		 * <code>const</code>.
		 */
		public function get isConstant():Boolean
		{
			return description.name() == "constant";
		}
		
		/**
		 * <code>true</code> if this is a property that has been defined with 
		 * <code>static</code>.
		 */
		public function get isStatic():Boolean
		{
			return description.parent().name() == "type";
		}
		
		/**
		 * The type that is defined for the property.
		 */
		public function get type():Type
		{
			return Type.reflect(getDefinitionByName(description.@type.toString()));
		}
	}
}