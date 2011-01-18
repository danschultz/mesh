package mesh.core.inflection
{
	import org.flexunit.assertThat;
	import org.hamcrest.object.equalTo;

	public class CamelizeTests
	{
		private var _tests:Array = [];
		
		[Before]
		public function setup():void
		{
			_tests.push({input:["the quick brown fox", false], expected:"theQuickBrownFox"});
			_tests.push({input:["the quick brown fox", true], expected:"TheQuickBrownFox"});
			_tests.push({input:["the quIck broWn foX", true], expected:"TheQuIckBroWnFoX"});
			_tests.push({input:["The quIck broWn foX", false], expected:"theQuIckBroWnFoX"});
			_tests.push({input:["the_quick_brown_fox", true], expected:"TheQuickBrownFox"});
			_tests.push({input:["the_ quick_ brown_ fox", true], expected:"TheQuickBrownFox"});
			_tests.push({input:["the _ quick _ brown _ fox", true], expected:"TheQuickBrownFox"});
			_tests.push({input:["the   quick  brown fox", true], expected:"TheQuickBrownFox"});
		}
		
		[Test]
		public function testCamelize():void
		{
			for each (var test:Object in _tests) {
				assertThat("camelize failed for '" + test.input[0] + "'", camelize.apply(null, test.input), equalTo(test.expected));
			}
		}
	}
}