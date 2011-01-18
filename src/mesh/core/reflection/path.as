package mesh.core.reflection
{
	import flash.utils.getQualifiedClassName;

	/**
	 * Returns the package name of the given object or class.
	 * 
	 * @param objectOrClass The object or class to get the package for.
	 * @return The package that the object or class belongs to.
	 */
	public function path(objectOrClass:Object):String
	{
		return getQualifiedClassName(objectOrClass).split("::").shift();
	}
}