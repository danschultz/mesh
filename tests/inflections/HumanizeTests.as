package inflections
{
	import org.flexunit.assertThat;
	import org.hamcrest.object.equalTo;

	public class HumanizeTests
	{
		private var _tests:Array = [];
		
		[Before]
		public function setup():void
		{
			_tests.push({input:"the quick brown fox", expected:"The quick brown fox"});
			_tests.push({input:"the quIck broWn foX", expected:"The qu ick bro wn fo x"});
			_tests.push({input:"the_quick_brown_fox", expected:"The quick brown fox"});
			_tests.push({input:"the_ quick_ brown_ fox", expected:"The quick brown fox"});
			_tests.push({input:"the _ quick _ brown _ fox", expected:"The quick brown fox"});
			_tests.push({input:"the   quick  brown fox", expected:"The quick brown fox"});
		}
		
		[Test]
		public function testHumanize():void
		{
			for each (var test:Object in _tests) {
				assertThat("humanize failed for '" + test.input + "'", humanize(test.input), equalTo(test.expected));
			}
		}
	}
}