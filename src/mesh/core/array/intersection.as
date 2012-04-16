package mesh.core.array
{
	/**
	 * Returns the intersection of the elements of each array. The intersection is where 
	 * the result is an array that contains the elements that are common amoung each input
	 * array.
	 * 
	 * @param args The arrays to intersect with.
	 * @return The intersecting elements.
	 */
	public function intersection(...args):Array
	{
		if (args.length == 0) {
			return [];
		}
		
		if (args.length == 1) {
			return args[0];
		}
		
		var result:Array = [];
		var lcd:Array;
		if (args.length == 2) {
			// Use the array with the least number of elements as the least common denominator.
			lcd = args.splice(args[0].length < args[1].length ? 0 : 1, 1).shift();
			var against:Array = args.shift();
			for each (var element:* in lcd) {
				if (against.indexOf(element) != -1) {
					result.push(element);
				}
			}
			return result;
		}
		
		lcd = args.sortOn("length", Array.NUMERIC).shift();
		while (args.length > 0) {
			result = result.concat(intersection(lcd, args.shift()));
		}
		return result;
	}
}