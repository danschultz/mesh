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
	 * var yesterday:MDate = MDate.today().previousDay();
	 * var today:MDate = MDate.today();
	 * trace(today > yesterday); // true
	 * </listing>
	 * </p>
	 * </p>
	 * 
	 * @see DateTime
	 * @author Dan Schultz
	 */
	public class MDate
	{
		/**
		 * Constructor.
		 * 
		 * @param epochTime The number of milliseconds since midnight on January 1, 1970 UTC.
		 */
		public function MDate(epochTime:Number = 0, offset:Number = 0)
		{
			_date = new Date(epochTime);
		}
		
		/**
		 * Constructor.
		 * 
		 * @param year The full year, i.e. 2011.
		 * @param month The month in the year.
		 * @param day The day in the month.
		 */
		public static function create(year:int, month:int = 1, day:int = 1):MDate
		{
			var d:Date = new Date(year, month-1, day);
			return new MDate(d.time);
		}
		
		/**
		 * Returns today's local date.
		 * 
		 * @return Today's date.
		 */
		public static function today():MDate
		{
			return new MDate(new Date().time);
		}
		
		/**
		 * Returns yesterday's local date.
		 * 
		 * @return Yesterday's date.
		 */
		public static function yesterday():MDate
		{
			return today().prevDay();
		}
		
		/**
		 * Returns tomorrow's local date.
		 * 
		 * @return Tomorrow's date.
		 */
		public static function tomorrow():MDate
		{
			return today().nextDay();
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
		public static function parse(obj:*):MDate
		{
			if (obj is String) {
				try {
					return MDate.create.apply(null, obj.split("-"));
				} catch (e:Error) {
					
				}
			}
			
			if (obj is Date) {
				return new MDate(obj.time);
			}
			
			throw new ArgumentError(clazz(MDate) + ".parse() cannot parse " + obj);
		}
		
		/**
		 * Returns a new date where its properties have changed to the values in the 
		 * <code>options</code> hash.
		 * 
		 * <strong>Example:</strong>
		 * <listing version="3.0">
		 * new MDate(2011, 1, 1).change({day:4}); // 2011-1-4
		 * bew MDate(2011, 1, 1).change({day:12, month:2}); // 2011-2-12
		 * </listing>
		 * 
		 * @param options The options hash.
		 * @return A new date.
		 */
		public function change(options:Object):*
		{
			return MDate.create(options.hasOwnProperty("year") ? options.year : year, 
								options.hasOwnProperty("month") ? options.month : month,
								options.hasOwnProperty("day") ? options.day : day);
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
		public function daysAgo(n:int = 1):*
		{
			return daysSince(-n);
		}
		
		/**
		 * Returns a new date where the date is the number of <code>n</code> days after 
		 * this date.
		 * 
		 * @param n The number of days to add.
		 * @return The next <code>n</code> days as a new date.
		 */
		public function daysSince(n:int = 1):*
		{
			return newInstance(clazz(this), valueOf() + (n * 86400000));
		}
		
		/**
		 * Returns a new date where the date is a day before this date.
		 * 
		 * @return The day before this date.
		 */
		public function prevDay():*
		{
			return daysAgo(1);
		}
		
		/**
		 * Returns a new date where the date is a day after this date.
		 * 
		 * @return The day after this date.
		 */
		public function nextDay():*
		{
			return daysSince(1);
		}
		
		/**
		 * Returns a new date where the date is the number of <code>n</code> months before 
		 * this date.
		 * 
		 * @param n The number of months to subtract.
		 * @return The previous <code>n</code> months as a new date.
		 */
		public function monthsAgo(n:int = 1):*
		{
			return monthsSince(-n);
		}
		
		/**
		 * Returns a new date where the date is the number of <code>n</code> months before 
		 * this date.
		 * 
		 * @param n The number of months to subtract.
		 * @return The next <code>n</code> months as a new date.
		 */
		public function monthsSince(n:int = 1):*
		{
			var m:int = month-1+n;
			var tempDate:Date = new Date(year, m, day);
			while (tempDate.month != m) {
				tempDate.date--;
			}
			return newInstance(clazz(this), tempDate.time);
		}
		
		/**
		 * Returns a new date where the date is a month before this date.
		 * 
		 * @return The month before this date.
		 */
		public function prevMonth():*
		{
			return monthsAgo(1);
		}
		
		/**
		 * Returns a new date where the date is a month after this date.
		 * 
		 * @return The month after this date.
		 */
		public function nextMonth():*
		{
			return monthsSince(1);
		}
		
		/**
		 * Returns a new date where the date is the number of <code>n</code> years before 
		 * this date.
		 * 
		 * @param n The number of years to subtract.
		 * @return The previous <code>n</code> years as a new date.
		 */
		public function yearsAgo(n:int = 1):*
		{
			return yearsSince(-n);
		}
		
		/**
		 * Returns a new date where the date is the number of <code>n</code> years after
		 * this date.
		 * 
		 * @param n The number of years to add.
		 * @return The next <code>n</code> years as a new date.
		 */
		public function yearsSince(n:int = 1):*
		{
			var m:int = month-1;
			var tempDate:Date = new Date(year+n, m, day);
			while (tempDate.month != m) {
				tempDate.date--;
			}
			return newInstance(clazz(this), tempDate.time);
		}
		
		/**
		 * Returns a new date where the date is a year before this date.
		 * 
		 * @return The year before this date.
		 */
		public function prevYear():*
		{
			return yearsAgo(1);
		}
		
		/**
		 * Returns a new date where the date is a year after this date.
		 * 
		 * @return The year after this date.
		 */
		public function nextYear():*
		{
			return yearsSince(1);
		}
		
		/**
		 * Returns a new instance of a native <code>Date</code>.
		 * 
		 * @return A date.
		 */
		public function toDate():Date
		{
			return new Date(_date.time);
		}
		
		/**
		 * Returns a new <code>DateTime</code> where the time is the beginning of this date's 
		 * date. The time zone can either be <code>local</code> time or <code>utc</code> time.
		 * 
		 * @return A new date time.
		 */
		public function toDateTime(timeZone:String = "local"):DateTime
		{
			var offset:Number;
			switch (timeZone) {
				case "local":
					offset = new Date().timezoneOffset;
					break;
				case "utc":
					offset = 0;
					break;
				default:
					throw new ArgumentError("Unrecognized time zone '" + timeZone + "'");
			}
			
			return new DateTime(year, month, day, 0, 0, 0, 0, offset);
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
			return _date.time;
		}
		
		private var _date:Date;
		/**
		 * The internal <code>Date</code> used to store this date's values.
		 */
		protected function get date():Date
		{
			return _date;
		}
		
		/**
		 * The day of the month.
		 */
		public function get day():int
		{
			return _date.date;
		}
		
		/**
		 * <code>true</code> if this date's year is a leap year.
		 */
		public function get isLeapYear():Boolean
		{
			return ((year % 100 != 0) && (year % 4 == 0)) || (year % 400 == 0);
		}
		
		/**
		 * <code>true</code> if the date resides before today.
		 */
		public function get inFuture():Boolean
		{
			return this > today();
		}
		
		/**
		 * <code>true</code> if the date resides before today.
		 */
		public function get inPast():Boolean
		{
			return this < today();
		}
		
		/**
		 * <code>true</code> if this date is today.
		 */
		public function get isToday():Boolean
		{
			var today:MDate = MDate.today();
			return year == today.year && month == today.month && day == today.day;
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