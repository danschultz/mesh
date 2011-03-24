package mesh.core.date
{
	import org.flexunit.assertThat;
	import org.hamcrest.object.equalTo;

	public class BaseDateTests
	{
		[Test]
		public function testParse():void
		{
			assertThat(BaseDate.parse("2011-2-13", equalTo("2011-2-13")));
		}
		
		[Test]
		public function testEquals():void
		{
			var today:Date = new Date();
			var yesterday:Date = new Date(new Date(today.time).setDate(today.date-1));
			
			assertThat(BaseDate.today().equals(BaseDate.parse("2010-1-1")), equalTo(false));
			assertThat(BaseDate.today().equals(BaseDate.today()), equalTo(true));
			assertThat(new BaseDate(today.fullYear, today.month-1, today.date-1).equals(yesterday), equalTo(false));
			assertThat(new BaseDate(today.fullYear, today.month-1, today.date-1).equals(today), equalTo(true));
			assertThat(new BaseDate(today.fullYear, today.month-1, today.date-1).equals(yesterday), equalTo(false));
		}
	}
}