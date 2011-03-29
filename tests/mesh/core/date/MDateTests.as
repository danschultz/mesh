package mesh.core.date
{
	import org.flexunit.assertThat;
	import org.hamcrest.object.equalTo;

	public class MDateTests
	{
		[Test]
		public function testParse():void
		{
			assertThat(MDate.parse("2011-2-13").toString(), equalTo("2011-2-13"));
		}
		
		[Test]
		public function testChange():void
		{
			var today:MDate = new MDate(2011, 1, 1);
			
			assertThat(today.change({month:2, day:5}).equals(new MDate(2011, 2, 5)), equalTo(true));
			assertThat(today.change({year:2012, month:3, day:10}).equals(new MDate(2012, 3, 10)), equalTo(true));
		}
		
		[Test]
		public function testEquals():void
		{
			var today:Date = new Date();
			var yesterday:Date = new Date(new Date(today.time).setDate(today.date-1));
			
			assertThat(MDate.today().equals(MDate.today()), equalTo(true));
			assertThat(MDate.today().equals(yesterday), equalTo(false));
		}
		
		[Test]
		public function testIsAfter():void
		{
			assertThat(MDate.tomorrow().isAfter(MDate.today()), equalTo(true));
			assertThat(MDate.yesterday().isAfter(MDate.today()), equalTo(false));
			assertThat(MDate.today().isAfter(MDate.today()), equalTo(false));
		}
		
		[Test]
		public function testIsBefore():void
		{
			assertThat(MDate.yesterday().isBefore(MDate.today()), equalTo(true));
			assertThat(MDate.tomorrow().isBefore(MDate.today()), equalTo(false));
			assertThat(MDate.today().isBefore(MDate.today()), equalTo(false));
		}
		
		[Test]
		public function testDaysAgo():void
		{
			assertThat(new MDate(2011, 1, 1).daysAgo(1).equals(new MDate(2010, 12, 31)), equalTo(true));
			assertThat(new MDate(2011, 1, 1).daysAgo(2).equals(new MDate(2010, 12, 30)), equalTo(true));
		}
		
		[Test]
		public function testDaysSince():void
		{
			assertThat(new MDate(2010, 12, 31).daysSince(1).equals(new MDate(2011, 1, 1)), equalTo(true));
			assertThat(new MDate(2010, 12, 31).daysSince(2).equals(new MDate(2011, 1, 2)), equalTo(true));
		}
		
		[Test]
		public function testPrevDay():void
		{
			assertThat(new MDate(2011, 1, 1).prevDay().equals(new MDate(2010, 12, 31)), equalTo(true));
		}
		
		[Test]
		public function testNextDay():void
		{
			assertThat(new MDate(2010, 12, 31).nextDay().equals(new MDate(2011, 1, 1)), equalTo(true));
		}
		
		[Test]
		public function testMonthsAgo():void
		{
			assertThat(new MDate(2011, 3, 31).monthsAgo(1).equals(new MDate(2011, 2, 28)), equalTo(true));
			assertThat(new MDate(2011, 3, 31).monthsAgo(2).equals(new MDate(2011, 1, 31)), equalTo(true));
			
			// test leap year is Feb 29th
			assertThat(new MDate(2004, 3, 31).monthsAgo(1).equals(new MDate(2004, 2, 29)), equalTo(true));
		}
		
		[Test]
		public function testMonthSince():void
		{
			assertThat(new MDate(2011, 1, 31).monthsSince(1).equals(new MDate(2011, 2, 28)), equalTo(true));
			assertThat(new MDate(2011, 1, 31).monthsSince(2).equals(new MDate(2011, 3, 31)), equalTo(true));
			
			// test leap year is Feb 29th
			assertThat(new MDate(2004, 1, 31).monthsSince(1).equals(new MDate(2004, 2, 29)), equalTo(true));
		}
		
		[Test]
		public function testPrevMonth():void
		{
			assertThat(new MDate(2011, 3, 31).prevMonth().equals(new MDate(2011, 2, 28)), equalTo(true));
		}
		
		[Test]
		public function testNextMonth():void
		{
			assertThat(new MDate(2011, 1, 31).nextMonth().equals(new MDate(2011, 2, 28)), equalTo(true));
		}
		
		[Test]
		public function testYearsAgo():void
		{
			assertThat(new MDate(2012, 2, 29).yearsAgo(1).equals(new MDate(2011, 2, 28)), equalTo(true));
		}
		
		[Test]
		public function testYearsSince():void
		{
			assertThat(new MDate(2012, 2, 29).yearsSince(1).equals(new MDate(2013, 2, 28)), equalTo(true));
		}
		
		[Test]
		public function testPrevYear():void
		{
			assertThat(new MDate(2012, 2, 29).prevYear().equals(new MDate(2011, 2, 28)), equalTo(true));
		}
		
		[Test]
		public function testNextYear():void
		{
			assertThat(new MDate(2012, 2, 29).yearsSince(1).equals(new MDate(2013, 2, 28)), equalTo(true));
		}
		
		[Test]
		public function testIsLeapYear():void
		{
			assertThat(new MDate(1800, 1, 1).isLeapYear, equalTo(false));
			assertThat(new MDate(2000, 1, 1).isLeapYear, equalTo(true));
			assertThat(new MDate(2004, 1, 1).isLeapYear, equalTo(true));
		}
	}
}