package validations
{
	import org.flexunit.assertThat;
	import org.hamcrest.object.equalTo;

	public class NumericValidatorTests
	{
		[Test]
		public function testValidate():void
		{
			var tests:Array = [
				{
					object:{num:5},
					options:{property:"num", lessThan:6},
					passes:true
				},
				{
					object:{num:5},
					options:{property:"num", lessThan:5},
					passes:false
				},
				{
					object:{num:5},
					options:{property:"num", lessThanOrEqualTo:5},
					passes:true
				},
				{
					object:{num:5},
					options:{property:"num", lessThanOrEqualTo:4},
					passes:false
				},
				{
					object:{num:5},
					options:{property:"num", greaterThan:4},
					passes:true
				},
				{
					object:{num:5},
					options:{property:"num", greaterThan:5},
					passes:false
				},
				{
					object:{num:5},
					options:{property:"num", greaterThanOrEqualTo:5},
					passes:true
				},
				{
					object:{num:5},
					options:{property:"num", greaterThanOrEqualTo:6},
					passes:false
				},
				{
					object:{num:5},
					options:{property:"num", equalTo:5},
					passes:true
				},
				{
					object:{num:5},
					options:{property:"num", equalTo:4},
					passes:false
				},
				{
					object:{num:5},
					options:{property:"num", between:"4..6"},
					passes:true
				},
				{
					object:{num:5},
					options:{property:"num", between:"1..3"},
					passes:false
				}
			];
			
			for (var i:int = 0; i < tests.length; i++) {
				var result:Array = new NumericValidator(tests[i].options).validate(tests[i].object);
				assertThat("validation failed for test " + i, result.length == 0, equalTo(tests[i].passes));
			}
		}
	}
}