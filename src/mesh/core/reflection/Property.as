package mesh.core.reflection
{
	import flash.utils.getDefinitionByName;

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
		 * Returns the value for this property on an object. If the property does not exist or is
		 * write only, an error is thrown.
		 * 
		 * @param object The object to get the value from.
		 * @return The property's value.
		 */
		public function value(object:Object):*
		{
			return isStatic ? reflect(object).clazz[name] : object[name];
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
			return description.parent().name() == "type" && description.parent().@isStatic == "true";
		}
		
		/**
		 * <code>true</code> if this is a property that can be read from.
		 */
		public function get isReadable():Boolean
		{
			return description.name() != "accessor" || description.@access.toString().search("read") != -1;
		}
		
		/**
		 * <code>true</code> if this is a property that can be read from.
		 */
		public function get isWritable():Boolean
		{
			return description.name() == "variable" || (!isConstant && description.@access.toString().search("write") != -1);
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