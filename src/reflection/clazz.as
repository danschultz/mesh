package reflection
{
	import flash.utils.getDefinitionByName;
	import flash.utils.getQualifiedClassName;

	/**
	 * Returns the class for the given object. The object can either be an instance of
	 * a class or a class reference itself.
	 * 
	 * @param obj The object to get the class for.
	 * @return The class reference for the object.
	 */
	public function clazz(obj:Object):Class
	{
		return getDefinitionByName(getQualifiedClassName(obj)) as Class;
	}
}