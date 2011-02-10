package mesh.core.number
{
	import org.flexunit.assertThat;
	import org.hamcrest.object.equalTo;

	public class RoundTests
	{
		private var _tests:Array;
		
		[Before]
		public function setup():void
		{
			_tests = [
				{number:123.4567, precision:3, expected:123.457},
				{number:123.4567, precision:2, expected:123.46},
				{number:123.4445, precision:2, expected:123.44},
				{number:123.4567, precision:1, expected:123.5},
				{number:123.5, precision:0, expected:124},
				{number:123.4, precision:0, expected:123},
				{number:-123.4, precision:0, expected:-123},
				{number:-123.5, precision:0, expected:-123},
				{number:-123.6, precision:0, expected:-124},
				{number:-123.4567, precision:1, expected:-123.5},
				{number:-123.4567, precision:3, expected:-123.457},
				{number:-123.4567, precision:2, expected:-123.46},
				{number:-123.4445, precision:2, expected:-123.44},
			];
		}
		
		[Test]
		public function testRound():void
		{
			for each (var test:Object in _tests) {
				assertThat("test failed for number," + test.number + ", with precision: " + test.precision, round(test.number, test.precision), equalTo(test.expected));
			}
		}
	}
}