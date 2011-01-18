package mesh.core.reflection
{
	/**
	 * Returns either a cached reflection object for the given class or object.
	 * 
	 * @param classOrObject The class or object to reflect.
	 * @return A reflection object.
	 */
	public function reflect(classOrObject:Object):Type
	{
		return Type.reflect(classOrObject);
	}
}