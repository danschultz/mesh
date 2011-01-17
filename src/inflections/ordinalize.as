package inflections
{
	/**
	 * Turns a number into an ordinal string used to symbolize the position in an
	 * ordered sequence, such as 1st, 2nd, 3rd.
	 * 
	 * <listing version="3.0">
	 * trace( ordinalize(1) ); // 1st
	 * trace( ordinalize(2) ); // 2nd
	 * trace( ordinalize(11) ); // 11th
	 * trace( ordinalize(1002) ); // 1002nd
	 * trace( ordinalize(1003) ); // 1003rd
	 * </listing>
	 * 
	 * @param number The number to ordinalize.
	 * @return The ordinalized string.
	 */
	public function ordinalize(number:Number):String
	{
		if ([11, 12, 13].indexOf(int( number ) % 100) != -1) {
			return number.toString() + "th";
		}
		
		switch (int( number ) % 10) {
			case 1:
				return number.toString() + "st";
			case 2:
				return number.toString() + "nd";
			case 3:
				return number.toString() + "rd";
		}
		
		return number.toString() + "th";
	}
}