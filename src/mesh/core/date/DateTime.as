package mesh.core.date
{
	/**
	 * A class that extends <code>MDate</code> to provide time information.
	 * 
	 * @author Dan Schultz
	 */
	public class DateTime extends MDate
	{
		/**
		 * Constructor.
		 * 
		 * @param epochTime The number of milliseconds since midnight on January 1, 1970 UTC.
		 */
		public function DateTime(epochTime:Number = 0, offset:Number = 0)
		{
			super(epochTime);
			_offset = offset;
		}
		
		/**
		 * Creates a new date time.
		 * 
		 * @param year The year.
		 * @param month The month of the year, between 1 and 12.
		 * @param day The day of the month.
		 * @param hour The hour of the day, between 0 and 23.
		 * @param minute The minute of the hour.
		 * @param second The second of the minute
		 * @param millisecond The millisecond in the second.
		 * @param offset The timezone offset in minutes.
		 * @return A new date time.
		 */
		public static function create(year:int, month:int = 1, day:int = 1, hour:int = 0, minute:int = 0, second:int = 0, millisecond:int = 0, offset:Number = 0):DateTime
		{
			var d:Date = new Date(year, month-1, day, hour, minute, second, millisecond);
		}
		
		public static function now():DateTime
		{
			var date:Date = new Date();
			return new DateTime(date.fullYear, date.month-1, date.date, date.hours, date.minutes, date.seconds, date.milliseconds, -date.timezoneOffset);
		}
		
		/**
		 * The hour in the day using a 24-hour clock, between 0 and 23.
		 */
		public function get hour():int
		{
			return date.hours;
		}
		
		/**
		 * The minutes in the hour, between 0 and 59.
		 */
		public function get minute():int
		{
			return date.minutes;
		}
		
		private var _offset:int;
		/**
		 * The time zone offset in minutes.
		 */
		public function get offset():int
		{
			return _offset;
		}
		
		/**
		 * The seconds in the minute, between 0 and 59.
		 */
		public function get second():int
		{
			return date.seconds;
		}
		
		/**
		 * The millisecond in the second.
		 */
		public function get millisecond():int
		{
			return date.milliseconds;
		}
		
		/**
		 * <code>true</code> if this date time has an offset of 0.
		 */
		public function get isUTC():Boolean
		{
			return offset == 0;
		}
	}
}