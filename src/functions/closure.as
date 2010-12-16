package functions
{
	/**
	 * Generates a function that can reference the variables defined within the scope 
	 * of the defined function, or the outer function that created it. For instance:
	 * 
	 * <listing version="3.0">
	 * var letters:Array = ["a", "b", "c", "d", "e"];
	 * var closures:Array = [];
	 * for each (var letter:String in letters) {
	 * 	closures.push(closure(function():void
	 * 	{
	 * 		trace(letter);
	 * 	}))
	 * }
	 * 
	 * for each (var closure:Function in closures) {
	 * 	closure();
	 * }
	 * 
	 * // traces:
	 * // a
	 * // b
	 * // c
	 * // d
	 * // e
	 * </listing>
	 * 
	 * @param func The function to close.
	 * @return A function closure.
	 */
	public function closure(func:Function):Function
	{
		var wrapper:Function = function(...args):*
		{
			var diff:int = func.length - args.length;
			if (diff > 0) {
				args = args.concat(new Array(diff));
			}
			return func.apply(null, args.slice(0, func.length));
		};
		return wrapper;
	}
}