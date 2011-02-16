package mesh.core.object
{
	/**
	 * Returns a new object that contains the values of <code>obj1</code> and the
	 * values from <code>obj2</code>. If the objects have conflicting keys, the resulting
	 * object will contain the value from <code>obj2</code>. You can overwrite this
	 * functionality by specifying a <code>block</code> function. This function must
	 * have the following signature: <code>function(key:String, old:Object, new:Object):Object</code>.
	 * 
	 * @param obj1 The original object.
	 * @param obj2 The object to merge with <code>obj1</code>.
	 * @param block A function to determine how to merge conflicting keys.
	 * @return The merged object.
	 */
	public function merge(obj1:Object, obj2:Object, block:Function = null):Object
	{
		obj1 = (obj1 == null ? {} : obj1);
		obj2 = (obj2 == null ? {} : obj2);
		
		if (block == null) {
			block = function(key:String, oldValue:Object, newValue:Object):Object
			{
				return newValue;
			};
		}
		
		var result:Object = {};
		
		for (var key1:String in obj1) {
			result[key1] = obj1[key1];
		}
		
		for (var key2:String in obj2) {
			result[key2] = !result.hasOwnProperty(key2) ? obj2[key2] : block(key2, result[key2], obj2[key2]);
		}
		
		return result;
	}
}