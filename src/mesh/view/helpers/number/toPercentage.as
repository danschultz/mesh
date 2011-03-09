package mesh.view.helpers.number
{
	/**
	 * Formats a number to a percentage string (i.e. 95%).
	 * 
	 * <p>
	 * <strong>Options:</strong>
	 * <ul>
	 * <li><code>precision:int</code> - The precision of the number. (default=<code>2</code>)</li>
	 * <li><code>significant:Boolean</code> - If <code>true</code>, the <code>precision</code> will 
	 * 	be the number of significant digits. (default=<code>false</code>)</li>
	 * <li><code>stripInsignificantZeros:Boolean</code> - If <code>true</code>, all insignificant 
	 * 	zeros after the separator will be removed. (default=<code>false</code>)</li>
	 * <li><code>delimiter:String</code> - The thousands delimiter. (default=<code>","</code>)</li>
	 * <li><code>separator:String</code> - The separator between the integer and fractions.
	 * 	(default=<code>"."</code>)</li>
	 * </ul>
	 * </p>
	 * 
	 * <p>
	 * <strong>Examples:</strong>
	 * <listing version="3.0">
	 * numberToPercentage(111.2345); // "111.23%"
	 * numberToPercentage(111.2345, {precision:3}); // "111.235%"
	 * numberToPercentage(12, {precision:3}); // "12.000%"
	 * numberToPercentage(234.5, {precision:0}); // "235%"
	 * numberToPercentage(111.234, {significant:true}); // "110%"
	 * numberToPercentage(111.234, {precision:1, significant:true}); // "100%"
	 * numberToPercentage(2, {precision:1, significant:true}); // "2%"
	 * numberToPercentage(15, {precision:1, significant:true}); // "20%"
	 * numberToPercentage(13, {precision:5, significant:true}); // "13.000%"
	 * numberToPercentage(13, {precision:5, significant:true, stripInsignificantZeros:true}); // "13%"
	 * numberToPercentage(389.32314, {precision:4, significant:true}); // "389.3%"
	 * numberToPercentage(1111.2345, {precision:2, separator:",", delimiter:"."}); // "1.111,23%"
	 * </listing>
	 * </p>
	 * 
	 * @param number The number to format.
	 * @param options The options to configure the format.
	 * @return A formatted string.
	 */
	public function toPercentage(number:Number, options:Object = null):String
	{
		return withPrecision(number, options) + "%";
	}
}