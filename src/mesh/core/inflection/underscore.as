package mesh.core.inflection
{
	/**
	 * Converts a camelized string, or string with whitespaces into a lower cased
	 * string with underscores.
	 * 
	 * @param str The string to convert.
	 * @return An underscored string.
	 */
	public function underscore(str:String):String
	{
		return camelize(str.replace(/-/g, "_")).replace(/([A-Z]+)([A-Z][a-z])/g, "$1_$2").replace(/([a-z\d])([A-Z])/g, "$1_$2").toLowerCase();
	}
}