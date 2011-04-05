package mesh.core.date
{
	import org.flexunit.assertThat;
	import org.hamcrest.object.equalTo;

	public class DateTimeTests
	{
		public function setup():void
		{
			
		}
		
		[Test]
		public function testDateUTC():void
		{
			var now:Date = new Date(Date.UTC(2011, 1, 28) + (480*60000));
			trace(now);
		}
	}
}