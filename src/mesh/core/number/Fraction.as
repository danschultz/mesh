package mesh.core.number
{
	/**
	 * The <code>Fraction</code> class represents a number that is part of a larger whole.
	 * This class stores fractions in the form of a <code>numerator</code> and <code>denominator</code>.
	 * 
	 * @author Dan Schultz
	 */
	public class Fraction
	{
		/**
		 * Constructor.
		 * 
		 * @param numerator The numerator of the fraction.
		 * @param denominator The denominator of the fraction.
		 */
		public function Fraction(numerator:int, denominator:int)
		{
			_numerator = numerator;
			_denominator = denominator;
		}
		
		/**
		 * Calculates the greatest common divisor of two integers using Stein's algorithm.
		 * 
		 * @param a The first integer.
		 * @param b The second integer.
		 * @return The greatest common divisor of <code>a</code> and <code>b</code>.
		 * @see http://en.wikipedia.org/wiki/Binary_GCD_algorithm Stein's algorithm
		 */
		public static function gcd(a:int, b:int):int
		{
			a = Math.abs(a);
			b = Math.abs(b);
			
			if (a == b) {
				return b;
			}
			if (a == 0) {
				return b;
			}
			if (b == 0) {
				return a;
			}
			
			if (a%2 == 0) { // if u is even
				if (b%2 == 0) { // if u and v are even
					return (2*gcd(a/2, b/2));
				} else { // u is even and v is odd
					return gcd(a/2, b);
				}
			} else if (b%2 == 0) { // if u is odd and v is even
				return gcd(a, b/2);
			}
			
			if (a >= b) {
				return gcd((a-b)/2, b);
			}
			return gcd((b-a)/2, a);
		}
		
		/**
		 * Calculates the lowest common multiple of two integers using Euclid's algorithm.
		 * 
		 * @param a The first integer.
		 * @param b The second integer.
		 * @return The lowest common multiple of <code>a</code> and <code>b</code>.
		 * @see http://en.wikipedia.org/wiki/Greatest_common_divisor Euclid's algorithm
		 */
		public static function lcm(a:int, b:int):int
		{
			return gcd(b, a%b);
		}
		
		/**
		 * Checks if two fractions or numbers are equal.
		 * 
		 * @param obj The object to check.
		 * @return <code>true</code> if the fraction or number are equal.
		 */
		public function equals(obj:Object):Boolean
		{
			return obj != null && obj.valueOf() === value;
		}
		
		/**
		 * Returns a string representation of this fraction in the form: <code>numerator + "/" + denominator</code>.
		 * 
		 * @return A string.
		 */
		public function toString():String
		{
			return numerator + "/" + denominator;
		}
		
		/**
		 * Returns a decimal representation of this fraction.
		 * 
		 * @return A decimal.
		 */
		public function toNumber():Number
		{
			return value;
		}
		
		/**
		 * Returns a representation of this fraction as a percentage where <code>100</code> represents <code>1/1</code>.
		 * 
		 * @return A percentage.
		 */
		public function toPercentage():Number
		{
			return value*100;
		}
		
		/**
		 * The primitive value of this fraction, which is a decimal.
		 * 
		 * @return A decimal.
		 */
		public function valueOf():Object
		{
			return value;
		}
		
		private var _denominator:int;
		/**
		 * The fractions denominator.
		 */
		public function get denominator():int
		{
			return _denominator;
		}
		
		private var _numerator:int;
		/**
		 * The fractions numerator.
		 */
		public function get numerator():int
		{
			return _numerator;
		}
		
		private function get value():Number
		{
			return numerator/denominator;
		}
	}
}