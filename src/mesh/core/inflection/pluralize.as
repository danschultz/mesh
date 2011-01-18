package mesh.core.inflection
{
	/**
	 * @copy Inflector#pluralize()
	 */
	public function pluralize(word:String):String
	{
		return Inflector.inflections().pluralize(word);
	}
}