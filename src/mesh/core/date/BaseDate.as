package mesh.core.date
{
	import mesh.core.reflection.clazz;
	import mesh.core.reflection.newInstance;

	/**
	 * A class that represents a day, month and year. This class does not include time
	 * information. To represent date and time, use <code>DateTime</code>. Once created,
	 * date classes are immutable.
	 * 
	 * <p>
	 * This class supports comparing dates using &lt;, &lt;=, &gt; and &gt;= operators.
	 * 
	 * <p>
	 * <strong>Example:</strong> Comparing dates using operators:
	 * <listing version="3.0">
	 * var yesterday:BaseDate = Date.today().previousDay();
	 * var today:BaseDate = Date.today();
	 * trace(today > yesterday); // true
	 * </listing>
	 * </p>
	 * </p>
	 * 
	 * @see DateTime
	 * @author Dan Schultz
	 */
	public class BaseDate
	{
		private var _date:Date;
		
		/**
		 * Constructor.
		 * 
		 * @param year The full year, i.e. 2011.
		 * @param month The month in the year.
		 * @param day The day in the month.
		 */
		public function BaseDate(year:int, month:int = 1, day:int = 1)
		{
			_date = new Date(year, month, day);
		}
		
		/**
		 * Returns today's local date.
		 * 
		 * @return Today's date.
		 */
		public static function today():BaseDate
		{
			var d:Date = new Date();
			return new BaseDate(d.fullYear, d.month+1, d.date+1);
		}
		
		/**
		 * Parses a date from the given object. This method can parse the following:
		 * 
		 * <ul>
		 * <li>A native <code>Date</code></li>
		 * <li>A string with the following format: 2011-02-13</li>
		 * </ul>
		 * 
		 * @param str The string to parse.
		 * @return A new date.
		 * @throws ArgumentError If <code>obj</code> cannot be parsed.
		 */
		public static function parse(obj:Object):BaseDate
		{
			if (obj is String) {
				try {
					return newInstance(BaseDate, str.split("-"));
				} catch (e:Error) {
					
				}
			}
			
			if (obj is Date) {
				return new Date(obj.fullYear, obj.month+1, obj.date+1);
			}
			
			throw new ArgumentError(clazz(this) + ".parse() cannot parse " + obj);
		}
		
		/**
		 * Checks a value for equality with this date.
		 * 
		 * <p>
		 * This date can be compared with <code>Date</code>, <code>DateTime</code> or any object
		 * who's <code>valueOf()</code> method returns the number of milliseconds since the epoch
		 * UTC.
		 * </p>
		 * 
		 * @param obj The object to compare.
		 * @return <code>true</code> if the dates are equal.
		 * 
		 * @see #isBefore()
		 * @see #isAfter()
		 */
		public function equals(obj:Object):Boolean
		{
			return obj != null && valueOf() === obj.valueOf();
		}
		
		/**
		 * Returns a unique hash for this date, where the hash is the number of milliseconds
		 * since the epoch.
		 * 
		 * @return A hash.
		 */
		public function hashCode():Object
		{
			return valueOf();
		}
		
		/**
		 * Checks if this date is after the given date.
		 * 
		 * <p>
		 * This date can be compared with <code>Date</code>, <code>DateTime</code> or any object
		 * who's <code>valueOf()</code> method returns the number of milliseconds since the epoch
		 * UTC.
		 * </p>
		 * 
		 * @param date The date to compare.
		 * @return <code>true</code> if this date is after <code>date</code>.
		 * 
		 * @see #equals()
		 * @see #isBefore()
		 */
		public function isAfter(date:Object):Boolean
		{
			return date != null && valueOf() > date.valueOf();
		}
		
		/**
		 * Checks if this date is before the given date.
		 * 
		 * <p>
		 * This date can be compared with <code>Date</code>, <code>DateTime</code> or any object
		 * who's <code>valueOf()</code> method returns the number of milliseconds since the epoch
		 * UTC.
		 * </p>
		 * 
		 * @param date The date to compare.
		 * @return <code>true</code> if this date is before <code>date</code>.
		 * 
		 * @see #equals()
		 * @see #isBefore()
		 */
		public function isBefore(date:Object):Boolean
		{
			return date != null && valueOf() < date.valueOf();
		}
		
		/**
		 * Returns a new date where the date is the number of <code>n</code> days before 
		 * this date.
		 * 
		 * @param n The number of days to subtract.
		 * @return The previous <code>n</code> days as a new date.
		 */
		public function previousDay(n:int = 1):BaseDate
		{
			return new BaseDate(year, month, day-n);
		}
		
		/**
		 * Returns a new date where the date is the number of <code>n</code> days after 
		 * this date.
		 * 
		 * @param n The number of days to add.
		 * @return The next <code>n</code> days as a new date.
		 */
		public function nextDay(n:int = 1):BaseDate
		{
			return new BaseDate(year, month, day+n);
		}
		
		/**
		 * Returns a new date where the date is the number of <code>n</code> months before 
		 * this date.
		 * 
		 * @param n The number of months to subtract.
		 * @return The previous <code>n</code> months as a new date.
		 */
		public function previousMonth(n:int = 1):BaseDate
		{
			return new BaseDate(year, month-n, day);
		}
		
		/**
		 * Returns a new date where the date is the number of <code>n</code> months before 
		 * this date.
		 * 
		 * @param n The number of months to subtract.
		 * @return The next <code>n</code> months as a new date.
		 */
		public function nextMonth(n:int = 1):BaseDate
		{
			return new BaseDate(year, month+n, day);
		}
		
		/**
		 * Returns a new date where the date is the number of <code>n</code> years before 
		 * this date.
		 * 
		 * @param n The number of years to subtract.
		 * @return The previous <code>n</code> years as a new date.
		 */
		public function previousYear(n:int = 1):BaseDate
		{
			return new BaseDate(year-n, month, day);
		}
		
		/**
		 * Returns a new date where the date is the number of <code>n</code> years after
		 * this date.
		 * 
		 * @param n The number of years to add.
		 * @return The next <code>n</code> years as a new date.
		 */
		public function nextYear(n:int = 1):BaseDate
		{
			return new BaseDate(year+n, month, day);
		}
		
		/**
		 * Returns a new instance of a native <code>Date</code>.
		 * 
		 * @return A date.
		 */
		public function toDate():Date
		{
			return new Date(valueOf());
		}
		
		/**
		 * @private
		 */
		public function toString():String
		{
			return year.toString() + "-" + month.toString() + "-" + day.toString();
		}
		
		/**
		 * Returns the number of milliseconds since midnight January 1, 1970 UTC.
		 * 
		 * @return A number.
		 */
		public function valueOf():Object
		{
			return toDate().time;
		}
		
		/**
		 * The day of the month.
		 */
		public function get day():int
		{
			return _date.date+1;
		}
		
		/**
		 * <code>true</code> if this date's year is a leap year.
		 */
		public function get isLeapYear():Boolean
		{
			return (year % 400 == 0) || (year % 100 == 0) || (year % 4 == 0);
		}
		
		/**
		 * The month of the year.
		 */
		public function get month():int
		{
			return _date.month+1;
		}
		
		/**
		 * The day of the week, where <code>0</code> is Sunday.
		 */
		public function get weekday():int
		{
			return _date.day;
		}
		
		/**
		 * The full year, i.e. 2011.
		 */
		public function get year():int
		{
			return _date.fullYear;
		}
	}
}