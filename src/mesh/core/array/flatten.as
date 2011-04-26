package mesh.core.array
{
	/**
	 * Returns a new one-dimensional array that is a recursive flattening of <code>elements</code>.
	 * Meaning, for each element in <code>elements</code> that is an array, insert its elements 
	 * into the new array.
	 * 
	 * <p>
	 * <strong>Examples:</strong>
	 * <listing version="3.0">
	 * var a:Array = [1, 2, 3];
	 * flatten(a); // [1, 2, 3]
	 * 
	 * var b:Array = [1, 2, 3, [4, 5]];
	 * flatten(b); // [1, 2, 3, 4, 5]
	 * 
	 * var c:Array = [1, 2, [3, [4, 5]]];
	 * flatten(c); // [1, 2, 3, 4, 5]
	 * flatten(c, 1); // [1, 2, 3, [4, 5]]
	 * </listing>
	 * </p>
	 * 
	 * @param elements The array to flatten.
	 * @depth The maximum depth to flatten.
	 * @return A new flattened array.
	 */
	public function flatten(elements:Object, depth:int = -1):Array
	{
		depth = depth < 0 ? int.MAX_VALUE : depth;
		elements = elements is Array ? elements : [elements];
		if (depth > 0) {
			var result:Array = [];
			for each (var element:Object in elements) {
				if (element is Array) {
					result = result.concat(flatten(element, depth-1));
					continue;
				}
				result.push(element);
			}
			return result;
		}
		return elements.concat();
	}
}