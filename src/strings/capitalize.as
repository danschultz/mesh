package strings
{
	/**
	 * Capitalizes the first letter of a string and the first letter after each 
	 * whitespace character.
	 * 
	 * @param str The string to capitalize.
	 * @return A capitalized string.
	 */
	public function capitalize(str:String):String
	{
		return str.replace(/(?:^|\s+)(.)/g, function():String
		{
			return arguments[1].toUpperCase();
		});
	}
}