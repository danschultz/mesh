package mesh.core.inflection
{
	import org.flexunit.assertThat;
	import org.hamcrest.object.equalTo;

	public class PluralizeTests
	{
		private var _tests:Array;
		
		[Before]
		public function setup():void
		{
			_tests = [
				// regulars
				{word:"dress", expected:"dresses"},
				{word:"horn", expected:"horns"},
				{word:"person", expected:"people"},
				{word:"orange", expected:"oranges"},
				
				// irregulars
				{word:"mouse", expected:"mice"},
				
				// uncountables
				{word:"moose", expected:"moose"},
				{word:"money", expected:"money"},
				{word:"deer", expected:"deer"},
				
				// already plural
				{word:"cats", expected:"cats"},
				{word:"addresses", expected:"addresses"}
			];
		}
		
		[Test]
		public function testPluralize():void
		{
			for each (var test:Object in _tests) {
				assertThat("test failed for " + test.word, pluralize(test.word), equalTo(test.expected));
			}
		}
	}
}