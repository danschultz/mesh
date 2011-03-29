package mesh.core.date
{
	/**
	 * A class that extends <code>MDate</code> to provide time information.
	 * 
	 * @author Dan Schultz
	 */
	public class DateTime extends MDate
	{
		private var _date:Date;
		
		/**
		 * Constructor.
		 * 
		 * @param year The year.
		 * @param month The month of the year, between 1 and 12.
		 * @param day The day of the month.
		 * @param hour The hour of the day, between 0 and 23.
		 * @param minute The minute of the hour.
		 * @param second The second of the minute
		 * @param millisecond The millisecond in the second.
		 * @param offset The timezone offset in minutes.
		 */
		public function DateTime(year:int, month:int = 1, day:int = 1, hour:int = 0, minute:int = 0, second:int = 0, millisecond:int = 0, offset:Number = 0)
		{
			_date = new Date(Date.UTC(year, month-1, day-1, hour, minute, second, millisecond) + (offset * 60000));
			super(_date.fullYear, _date.month+1, _date.date);
		}
		
		public static function now():DateTime
		{
			var date:Date = new Date();
			return new DateTime(date.fullYearUTC, date.monthUTC+1, date.dateUTC+1, date.hoursUTC, date.minutesUTC, date.secondsUTC, date.millisecondsUTC, date.timezoneOffset);
		}
		
		/**
		 * @inheritDoc
		 */
		override public function toDate():Date
		{
			return new Date(_date.time);
		}
		
		/**
		 * The hour in the day using a 24-hour clock, between 0 and 23.
		 */
		public function get hour():int
		{
			return _date.hours;
		}
		
		/**
		 * The minutes in the hour, between 0 and 59.
		 */
		public function get minutes():int
		{
			return _date.minutes;
		}
		
		/**
		 * The time zone offset in minutes.
		 */
		public function get offset():int
		{
			return _date.timezoneOffset;
		}
		
		/**
		 * The seconds in the hour, between 0 and 59.
		 */
		public function get seconds():int
		{
			return _date.seconds;
		}
	}
}