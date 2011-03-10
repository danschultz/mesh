package mesh.core.inflection
{
	import org.flexunit.assertThat;
	import org.hamcrest.object.equalTo;

	public class SingularizeTests
	{
		private var _tests:Array;
		
		[Before]
		public function setup():void
		{
			_tests = [
				// regulars
				{word:"dresses", expected:"dress"},
				{word:"horns", expected:"horn"},
				{word:"people", expected:"person"},
				{word:"oranges", expected:"orange"},
				
				// irregulars
				{word:"mice", expected:"mouse"},
				
				// uncountables
				{word:"moose", expected:"moose"},
				{word:"money", expected:"money"},
				{word:"deer", expected:"deer"},
				
				// already singular
				{word:"address", expected:"address"}
			];
		}
		
		[Test]
		public function testSingularize():void
		{
			for each (var test:Object in _tests) {
				assertThat("test failed for " + test.word, singularize(test.word), equalTo(test.expected));
			}
		}
	}
}