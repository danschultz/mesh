package mesh.validators
{
	
	import org.flexunit.assertThat;
	import org.hamcrest.object.equalTo;
	
	import reflection.inspect;

	public class LengthValidatorTests
	{
		[Test]
		public function testValidate():void
		{
			var tests:Array = [
				{
					object:{str:"Hello", errors:new Errors(null)},
					options:{property:"str", minimum:5},
					passes:true
				},
				{
					object:{str:"Hello", errors:new Errors(null)},
					options:{property:"str", minimum:6},
					passes:false
				},
				{
					object:{str:"Hello", errors:new Errors(null)},
					options:{property:"str", maximum:5},
					passes:true
				},
				{
					object:{str:"Hello", errors:new Errors(null)},
					options:{property:"str", maximum:4},
					passes:false
				},
				{
					object:{str:"Hello", errors:new Errors(null)},
					options:{property:"str", between:"0..5"},
					passes:true
				},
				{
					object:{str:"Hello", errors:new Errors(null)},
					options:{property:"str", between:"1..5"},
					passes:true
				},
				{
					object:{str:"Hello", errors:new Errors(null)},
					options:{property:"str", between:"0..4"},
					passes:false
				},
				{
					object:{str:"Hello", errors:new Errors(null)},
					options:{property:"str", between:"0..6"},
					passes:true
				},
				{
					object:{str:"Hello", errors:new Errors(null)},
					options:{property:"str", length:"5"},
					passes:true
				},
				{
					object:{str:"Hello", errors:new Errors(null)},
					options:{property:"str", length:"4"},
					passes:false
				}
			];
			
			for each (var test:Object in tests) {
				new LengthValidator(test.options).validate(test.object);
				assertThat("validation failed for test " + inspect(test.options), test.object.errors.length == 0, equalTo(test.passes));
			}
		}
	}
}