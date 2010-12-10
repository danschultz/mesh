package strings
{
	import org.flexunit.assertThat;
	import org.hamcrest.object.equalTo;

	public class CapitalizeTests
	{
		private var _tests:Array = [];
		
		[Before]
		public function setup():void
		{
			_tests.push({input:"the quick brown fox", expected:"The Quick Brown Fox"});
			_tests.push({input:"the quIck broWn foX", expected:"The QuIck BroWn FoX"});
			_tests.push({input:"the_quick_brown_fox", expected:"The_quick_brown_fox"});
			_tests.push({input:"the_ quick_ brown_ fox", expected:"The_ Quick_ Brown_ Fox"});
			_tests.push({input:"the _ quick _ brown _ fox", expected:"The _ Quick _ Brown _ Fox"});
			_tests.push({input:"the   quick  brown fox", expected:"The   Quick  Brown Fox"});
		}
		
		[Test]
		public function testCapitalize():void
		{
			for each (var test:Object in _tests) {
				assertThat("capitalize failed for '" + test.input + "'", capitalize(test.input), equalTo(test.expected));
			}
		}
	}
}