package mesh.view.helpers.number
{
	import mesh.core.object.merge;

	/**
	 * Formats a number with a delimiter (123,000) and a separator (123,000.1).
	 * 
	 * <p>
	 * <strong>Options:</strong>
	 * <ul>
	 * <li><code>delimiter</code> (default=<code>","</code>) - The thousands delimiter.</li>
	 * <li><code>separator</code> (default=<code>"."</code>) - The separator between the integer 
	 * 	and fractions.</li>
	 * </ul>
	 * </p>
	 * 
	 * @param number The number to format.
	 * @param options The options to use.
	 * @return A delimited number as a string.
	 */
	public function numberWithDelimiter(number:Number, options:Object = null):String
	{
		options = merge({delimiter:",", separator:"."}, options);
		
		var parts:Array = number.toString().split(".");
		parts[0] = parts[0].replace(/(\d)(?=(\d\d\d)+(?!\d))/g, "$&" + options.delimiter);
		return parts.join(options.separator);
	}
}