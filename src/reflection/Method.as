package reflection
{
	import flash.utils.getDefinitionByName;
	
	/**
	 * A class that represents the functions that has been defined on a class, variable, or
	 * method.
	 * 
	 * @author Dan Schultz
	 */
	public class Method extends Definition
	{
		/**
		 * @copy Definition#Definition()
		 */
		public function Method(description:XML, belongsTo:Definition)
		{
			super(description, belongsTo);
		}
		
		/**
		 * <code>true</code> if this is a method that has been defined with 
		 * <code>static</code>.
		 */
		public function get isStatic():Boolean
		{
			return description.parent().name() == "type";
		}
		
		/**
		 * The definition that represents the type that is returned from a function call to
		 * this method. If no return type is defined, this method returns null.
		 */
		public function get returnType():Type
		{
			return description.@returnType.toString() == "void" ? null : Type.reflect(getDefinitionByName(description.@returnType.toString()) as Class);
		}
	}
}