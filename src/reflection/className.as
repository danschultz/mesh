package reflection
{
	import flash.utils.getQualifiedClassName;

	/**
	 * Returns the name of the class for the given object. The returned name does not
	 * include the package or namespace that the class resides in. The object can either
	 * be an instance of a class, or the class itself.
	 * 
	 * @param obj The object to get the class name for.
	 * @return The name of the class.
	 */
	public function className(obj:Object):String
	{
		return getQualifiedClassName(obj).split("::").pop();
	}
}