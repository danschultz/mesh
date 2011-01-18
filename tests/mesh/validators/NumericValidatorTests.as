package mesh.validators
{
	
	import org.flexunit.assertThat;
	import org.hamcrest.object.equalTo;
	
	import reflection.inspect;

	public class NumericValidatorTests
	{
		[Test]
		public function testValidate():void
		{
			var tests:Array = [
				{
					object:{num:5, errors:new Errors(null)},
					options:{property:"num", odd:true},
					passes:true
				},
				{
					object:{num:4, errors:new Errors(null)},
					options:{property:"num", odd:true},
					passes:false
				},
				{
					object:{num:4, errors:new Errors(null)},
					options:{property:"num", even:true},
					passes:true
				},
				{
					object:{num:5, errors:new Errors(null)},
					options:{property:"num", even:true},
					passes:false
				},
				{
					object:{num:5, errors:new Errors(null)},
					options:{property:"num", lessThan:6},
					passes:true
				},
				{
					object:{num:5, errors:new Errors(null)},
					options:{property:"num", lessThan:5},
					passes:false
				},
				{
					object:{num:5, errors:new Errors(null)},
					options:{property:"num", lessThanOrEqualTo:5},
					passes:true
				},
				{
					object:{num:5, errors:new Errors(null)},
					options:{property:"num", lessThanOrEqualTo:4},
					passes:false
				},
				{
					object:{num:5, errors:new Errors(null)},
					options:{property:"num", greaterThan:4},
					passes:true
				},
				{
					object:{num:5, errors:new Errors(null)},
					options:{property:"num", greaterThan:5},
					passes:false
				},
				{
					object:{num:5, errors:new Errors(null)},
					options:{property:"num", greaterThanOrEqualTo:5},
					passes:true
				},
				{
					object:{num:5, errors:new Errors(null)},
					options:{property:"num", greaterThanOrEqualTo:6},
					passes:false
				},
				{
					object:{num:5, errors:new Errors(null)},
					options:{property:"num", equalTo:5},
					passes:true
				},
				{
					object:{num:5, errors:new Errors(null)},
					options:{property:"num", equalTo:4},
					passes:false
				},
				{
					object:{num:5, errors:new Errors(null)},
					options:{property:"num", between:"4..6"},
					passes:true
				},
				{
					object:{num:5, errors:new Errors(null)},
					options:{property:"num", between:"1..3"},
					passes:false
				},
				{
					object:{num:5.5, errors:new Errors(null)},
					options:{property:"num", integer:true},
					passes:false
				},
				{
					object:{num:5, errors:new Errors(null)},
					options:{property:"num", integer:true},
					passes:true
				},
				{
					object:{num:"abc", errors:new Errors(null)},
					options:{property:"num"},
					passes:false
				}
			];
			
			for each (var test:Object in tests) {
				new NumericValidator(test.options).validate(test.object);
				assertThat("validation failed for test " + inspect(test.options), test.object.errors.length == 0, equalTo(test.passes));
			}
		}
	}
}