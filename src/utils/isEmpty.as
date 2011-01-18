package utils
{
	import mx.utils.StringUtil;

	/**
	 * Checks if the given object is empty. If the object is a string, it checks if the 
	 * string is empty or only contains whitespace. If the object is a number, it checks if
	 * the number is <code>NaN</code>. If the object contains either a <code>length</code> or
	 * <code>isEmpty</code> property or method, the result will be evaluated.
	 * 
	 * @param obj The object to check.
	 * @return <code>true</code> if the object is empty.
	 */
	public function isEmpty(obj:Object):Boolean
	{
		if (obj == null) {
			return true;
		}
		
		if (obj is String) {
			return StringUtil.trim(obj as String).length == 0;
		}
		
		if (obj is Number) {
			return isNaN(obj as Number);
		}
		
		if (obj.hasOwnProperty("isEmpty")) {
			if (obj.isEmpty is Function) {
				return obj.isEmpty();
			}
			return obj.isEmpty;
		}
		
		if (obj.hasOwnProperty("length")) {
			if (obj.length is Function) {
				return obj.length() == 0;
			}
			return obj.length == 0;
		}
		
		return false;
	}
}