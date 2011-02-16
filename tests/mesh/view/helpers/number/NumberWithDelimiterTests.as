package mesh.view.helpers.number
{
	import mesh.core.object.inspect;
	
	import org.flexunit.assertThat;
	import org.hamcrest.object.equalTo;

	public class NumberWithDelimiterTests
	{
		private var _tests:Array;
		
		[Before]
		public function setup():void
		{
			_tests = [
				{number:12345678, options:null, expected:"12,345,678"},
				{number:12345678.05, options:null, expected:"12,345,678.05"},
				{number:12345678, options:{delimiter:"."}, expected:"12.345.678"},
				{number:12345678, options:{separator:","}, expected:"12,345,678"},
				{number:12345678.05, options:{delimiter:" ", separator:","}, expected:"12 345 678,05"}
			];
		}
		
		[Test]
		public function testNumberWithDelimiter():void
		{
			for each (var test:Object in _tests) {
				assertThat("test failed for number," + test.number + ", with options: " + inspect(test.options), numberWithDelimiter(test.number, test.options), equalTo(test.expected));
			}
		}
	}
}