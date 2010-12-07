package inflections
{
	import strings.sentenceize;

	/**
	 * First converts the given string to an underscored string, then capitalizes the first
	 * word and turns underscores into spaces.
	 * 
	 * @param str The string to humanize.
	 * @return A humanized string.
	 */
	public function humanize(str:String):String
	{
		return sentenceize(underscore(str).replace(/_/g, " "));
	}
}