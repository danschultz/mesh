package mesh.view.helpers.number
{
	import mesh.core.number.round;
	import mesh.core.object.merge;

	/**
	 * Formats a number with a certain level of precision. For example, <code>123.45</code> has 
	 * a precision of 2 when <code>significant</code> is <code>false</code>, and a precision of
	 * 5 when <code>significant</code> is <code>true</code>.
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
	 * numberWithPrecision(111.2345); // "111.23"
	 * numberWithPrecision(111.2345, {precision:3}); // "111.235"
	 * numberWithPrecision(12, {precision:3}); // "12.000"
	 * numberWithPrecision(234.5, {precision:0}); // "235"
	 * numberWithPrecision(111.234, {significant:true}); // "110"
	 * numberWithPrecision(111.234, {precision:1, significant:true}); // "100"
	 * numberWithPrecision(2, {precision:1, significant:true}); // "2"
	 * numberWithPrecision(15, {precision:1, significant:true}); // "20"
	 * numberWithPrecision(13, {precision:5, significant:true}); // "13.000"
	 * numberWithPrecision(13, {precision:5, significant:true, stripInsignificantZeros:true}); // "13"
	 * numberWithPrecision(389.32314, {precision:4, significant:true}); // "389.3"
	 * numberWithPrecision(1111.2345, {precision:2, separator:",", delimiter:"."}); // "1.111,23"
	 * </listing>
	 * </p>
	 * 
	 * @param number The number to format.
	 * @param options The options to configure the format.
	 * @return A formatted string.
	 */
	public function withPrecision(number:Number, options:Object = null):String
	{
		options = merge({precision:2, significant:false, stripInsignificantZeros:false, delimiter:",", separator:"."}, options);
		
		var digits:Number = 1;
		var roundedNumber:Number = 0;
		var formattedNumber:String;
		var significant:Boolean = options.significant;
		var stripInsignificantZeros:Boolean = options.stripInsignificantZeros;
		var precision:int = options.precision;
		var separator:String = options.separator;
		
		if (significant && precision > 0) {
			if (number != 0) {
				digits = Math.ceil(Math.log(number < 0 ? -number: number) * Math.LOG10E);
				var magnitude:Number = Math.pow(10, precision - digits);
				roundedNumber = Math.round(number*magnitude) / magnitude;
			}
			
			precision = precision - digits;
			precision = precision > 0 ? precision : 0;
		} else {
			roundedNumber = round(number, precision);
		}
		formattedNumber = roundedNumber.toFixed(precision);
		
		var parts:Array = withDelimiter(roundedNumber, options).split(separator);
		if (formattedNumber.indexOf(separator) != -1) {
			parts[1] = formattedNumber.split(separator)[1];
		}
		formattedNumber = parts.join(separator);
		
		if (stripInsignificantZeros) {
			formattedNumber = formattedNumber.split(separator).shift();
		}
		
		return formattedNumber;
	}
}