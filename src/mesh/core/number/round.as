package mesh.core.number
{
	/**
	 * Rounds a number to the given precision.
	 * 
	 * @param number The number to round.
	 * @param precision The number of fractional digits.
	 * @return The rounded number.
	 */
	public function round(number:Number, precision:int = 0):Number
	{
		return number.toFixed(precision < 0 ? 0 : precision) as Number;
	}
}