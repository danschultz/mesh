package strings
{
	/**
	 * Capitalizes the first letter of each sentence in the string.
	 * 
	 * @param sentences The sentences to capitalize.
	 * @return A capitalized sentence.
	 */
	public function sentenceize(sentences:String):String
	{
		return sentences.replace(/(^|[\.|\?|!]\s+)(.)/gm, function():String
		{
			return arguments[1] + arguments[2].toUpperCase();
		});
	}
}