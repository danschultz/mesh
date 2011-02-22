package mesh.core.object
{
	/**
	 * Copies the enumerable values defined on <code>from</code> to <code>to</code>. If a key
	 * exists on <code>from</code>, but not on <code>to</code>, its value is not copied.
	 * 
	 * <p>
	 * Additional options can be passed in to configure the copy:
	 * 
	 * <ul>
	 * <li>ignore:<code>Array</code> - A list of properties to not copy.</li>
	 * </ul>
	 * </p>
	 * 
	 * @param from The object who's values to copy from.
	 * @param to The object to copy to.
	 * @param options Configurable options.
	 * @throws ReferenceError If a key exists on <code>from</code> that is a defined function
	 * 	on <code>to</code>.
	 */
	public function copy(from:Object, to:Object, options:Object = null):void
	{
		options = options == null ? {} : options;
		
		var ignore:Array = (options.ignore is Array) ? options.ignore : null;
		
		for (var key:String in from) {
			if (to.hasOwnProperty(key) && to[key] != from[key]) {
				if (ignore == null || ignore.indexOf(key) == -1) {
					to[key] = from[key];
				}
			}
		}
	}
}