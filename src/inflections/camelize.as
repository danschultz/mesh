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
	public function camelize(str:String, uppercaseFirstLetter:Boolean = true):String
	{
		str = str.replace(/(?:_|\s)+(.)/g, function():String
		{
			return arguments[1].toUpperCase();
		});
		return uppercaseFirstLetter ? str.substr(0, 1).toUpperCase() + str.substr(1) : str;
	}
}