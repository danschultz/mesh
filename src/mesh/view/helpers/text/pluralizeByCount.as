package mesh.view.helpers.text
{
	import mesh.core.inflection.pluralize;

	/**
	 * Pluralizes a <code>singular</code> word based on its <code>count</code>. The word
	 * is pluralized if and only if <code>count < 1 < count</code>. If <code>plural</code>
	 * is given, then that word will be used. Otherwise an inflection will be used.
	 * 
	 * <p>
	 * <strong>Examples:</strong>
	 * <listing version="3.0">
	 * trace( pluralize(2, "person") ); // 2 people
	 * trace( pluralize(-2, "person") ); // -2 people
	 * trace( pluralize(1, "fish") ); // 1 fish
	 * trace( pluralize(0, "fish") ); // 0 fishes
	 * trace( pluralize(2, "cake", "desserts") ); // 2 desserts
	 * trace( pluralize(2, "cake", "desserts") ); // 2 desserts
	 * </listing>
	 * </p>
	 * 
	 * @return Either a singular or pluralized word when <code>count</code> is not 1.
	 * @see mesh.core.inflection.pluralize()
	 */
	public function pluralizeByCount(count:Number, singular:String, plural:String = null):String
	{
		return count.toString() + " " + (count == 1 ? singular : (plural != null) ? plural : pluralize(singular));
	}
}