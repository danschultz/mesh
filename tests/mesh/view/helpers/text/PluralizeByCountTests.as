package mesh.view.helpers.text
{
	import org.flexunit.assertThat;
	import org.hamcrest.object.equalTo;

	public class PluralizeByCountTests
	{
		private var _tests:Array;
		
		[Before]
		public function setup():void
		{
			_tests = [
				{args:[-1, "person"], expected:"-1 people"},
				{args:[0, "person"], expected:"0 people"},
				{args:[1, "person"], expected:"1 person"},
				{args:[2, "person"], expected:"2 people"},
				{args:[1, "cake", "desserts"], expected:"1 cake"},
				{args:[2, "cake", "desserts"], expected:"2 desserts"}
			];
		}
		
		[Test]
		public function testPluralize():void
		{
			for each (var test:Object in _tests) {
				assertThat("test failed for args '" + test.args + "'", pluralizeByCount.apply(null, test.args), equalTo(test.expected));
			}
		}
	}
}