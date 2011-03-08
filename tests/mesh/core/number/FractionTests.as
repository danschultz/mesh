package mesh.core.number
{
	import mesh.core.object.inspect;
	
	import org.flexunit.assertThat;
	import org.hamcrest.object.equalTo;

	public class FractionTests
	{
		[Test]
		public function testGCD():void
		{
			var tests:Array = [
				{a:1, b:2, expected:1},
				{a:0, b:3, expected:3},
				{a:3, b:0, expected:3},
				{a:108, b:30, expected:6},
				{a:-108, b:30, expected:6},
				{a:108, b:-30, expected:6},
				{a:-108, b:-30, expected:6}
			];
			
			for each (var test:Object in tests) {
				assertThat("test failed: " + inspect(test), Fraction.gcd(test.a, test.b), equalTo(test.expected));
			}
		}
	}
}