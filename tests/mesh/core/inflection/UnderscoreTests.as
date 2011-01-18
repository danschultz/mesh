package mesh.core.inflection
{
	import org.flexunit.assertThat;
	import org.hamcrest.object.equalTo;

	public class UnderscoreTests
	{
		private var _tests:Array = [];
		
		[Before]
		public function setup():void
		{
			_tests.push({input:"TheQuickBrownFox", expected:"the_quick_brown_fox"});
			_tests.push({input:"THEQuickBrownFox", expected:"the_quick_brown_fox"});
			_tests.push({input:"TheQUICKBrownFox", expected:"the_quick_brown_fox"});
			_tests.push({input:"TheQUICKBrownFOX", expected:"the_quick_brown_fox"});
			_tests.push({input:"The Quick Brown Fox", expected:"the_quick_brown_fox"});
			_tests.push({input:"The quick brown fox", expected:"the_quick_brown_fox"});
			_tests.push({input:"the quick brown fox", expected:"the_quick_brown_fox"});
			_tests.push({input:"the   quick  brown fox", expected:"the_quick_brown_fox"});
			_tests.push({input:"the _ quick - brown-fox", expected:"the_quick_brown_fox"});
		}
		
		[Test]
		public function testUnderscore():void
		{
			for each (var test:Object in _tests) {
				assertThat("underscore failed for '" + test.input + "'", underscore.call(null, test.input), equalTo(test.expected));
			}
		}
	}
}