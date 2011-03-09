package mesh.core.number
{
	/**
	 * Generates a pseudo-random number. If <code>max</code> and <code>min</code> are zero, the 
	 * result is a number where <code>0 <= n < 1</code>. If max is non-zero, then the result is 
	 * a number where <code>min <= n <= max</code>. If max is less than 0, it is first absoluted 
	 * then treated as a non-zero number.
	 * 
	 * <p>
	 * This method attempts to generate a well-balanced random number. This is done by first adding 
	 * <code>0.5</code> to the max, and subtracting <code>0.5</code> from the min. The altered max
	 * and min is then multiplied against <code>Math.random()</code>, and the result rounded to the
	 * nearest integer.
	 * </p>
	 * 
	 * @param max The highest value for the result.
	 * @param min The lowest value for the result.
	 * @return A pseudo-random number.
	 */
	public function random(max:int = 0, min:int = 0):Number
	{
		if (max != 0 || min != 0) {
			var high:Number = Math.max(max, min) + 0.5;
			var low:Number = Math.min(min, max) - 0.5;
			return Math.round((Math.random() * (high - low)) + low);
		}
		return Math.random();
	}
}