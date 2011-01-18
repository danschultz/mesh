package mesh.core.inflection
{
	/**
	 * @copy Inflector#singularize()
	 */
	public function singularize(word:String):String
	{
		return Inflector.inflections().singularize(word);
	}
}