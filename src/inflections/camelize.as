package inflections
{
	/**
	 * Returns a camelized version of a string, where the underscores and whitespaces 
	 * are removed.
	 * 
	 * @param str The string to camelize.
	 * @param uppercaseFirstLetter <code>true</code> if the first letter of the result
	 * 	is uppercased.
	 * @return A camelized string.
	 */
	public function camelize(str:String, uppercaseFirstLetter:Boolean = false):String
	{
		if (uppercaseFirstLetter) {
			return str.replace(/(?:^|_|\s)+(.)/g, function():String
			{
				return arguments[1].toUpperCase();
			});
		}
		return str.substr(0, 1).toLowerCase() + camelize(str.substr(1), false);
	}
}