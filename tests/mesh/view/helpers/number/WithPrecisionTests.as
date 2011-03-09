package mesh.view.helpers.number
{
	import mesh.core.object.inspect;
	
	import org.flexunit.assertThat;
	import org.hamcrest.object.equalTo;

	public class WithPrecisionTests
	{
		private var _tests:Array;
		
		[Before]
		public function setup():void
		{
			_tests = [
				{number:111.2345, options:null, expected:"111.23"},
				{number:111.2345, options:{precision:3}, expected:"111.235"},
				{number:12, options:{precision:3}, expected:"12.000"},
				{number:234.5, options:{precision:0}, expected:"235"},
				{number:111.234, options:{significant:true}, expected:"110"},
				{number:111.234, options:{precision:1, significant:true}, expected:"100"},
				{number:2, options:{precision:1, significant:true}, expected:"2"},
				{number:15, options:{precision:1, significant:true}, expected:"20"},
				{number:13, options:{precision:5, significant:true}, expected:"13.000"},
				{number:13, options:{precision:5, significant:true, stripInsignificantZeros:true}, expected:"13"},
				{number:389.32314, options:{precision:4, significant:true}, expected:"389.3"},
				{number:1111.2345, options:{precision:2, separator:",", delimiter:"."}, expected:"1.111,23"},
			];
		}
		
		[Test]
		public function testNumberWithPrecision():void
		{
			for each (var test:Object in _tests) {
				assertThat("test failed for number," + test.number + ", with options: " + inspect(test.options), withPrecision(test.number, test.options), equalTo(test.expected));
			}
		}
	}
}