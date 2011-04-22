package mesh.core.object
{
	/**
	 * Copies the enumerable values defined on <code>from</code> to <code>to</code>. If 
	 * <code>to</code> is a non-dynamic class, and a key exists on <code>from</code>, but 
	 * not on <code>to</code>, its value is not copied.
	 * 
	 * <p>
	 * Additional options can be passed in to configure the copy:
	 * 
	 * <ul>
	 * <li>excludes:<code>Array</code> - A list of properties to not copy.</li>
	 * <li>includes:<code>Array</code> - A list of properties to copy.</li>
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
		
		var includes:Array = (options.includes is Array) ? options.includes : [];
		var excludes:Array = (options.excludes is Array) ? options.excludes : [];
		
		for (var key:String in from) {
			if (includes.indexOf(key) == -1) {
				includes.push(key);
			}
		}
		
		for each (key in includes) {
			try {
				if (to[key] != from[key]) {
					if (excludes.indexOf(key) == -1) {
						to[key] = from[key];
					}
				}
			} catch (e:ReferenceError) {
				
			}
		}
	}
}