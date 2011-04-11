package mesh.core.array
{
	import org.flexunit.assertThat;
	import org.hamcrest.collection.array;
	import org.hamcrest.object.equalTo;

	public class FlattenTests
	{
		[Test]
		public function testFlatten():void
		{
			var tests:Array = [
				{elements:[1, 2, 3], expected:[1, 2, 3]},
				{elements:[1, 2, 3, [4, 5]], expected:[1, 2, 3, 4, 5]},
				{elements:[1, 2, [3, [4, 5]]], expected:[1, 2, 3, 4, 5]},
				{elements:[1, 2, [3, [4, 5]]], depth:1, expected:[1, 2, 3, [4, 5]]},
				{elements:1, expected:[1]}
			];
			
			for each (var test:Object in tests) {
				assertThat("test failed with elements: " + test.elements, test.depth != null ? flatten(test.elements, test.depth) : flatten(test.elements), array.apply(null, test.expected));
			}
		}
	}
}