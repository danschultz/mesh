package validations
{
	import org.flexunit.assertThat;
	import org.hamcrest.object.equalTo;
	import mesh.validators.LengthValidator;

	public class LengthValidatorTests
	{
		[Test]
		public function testValidate():void
		{
			var tests:Array = [
				{
					object:{str:"Hello"},
					options:{property:"str", minimum:5},
					passes:true
				},
				{
					object:{str:"Hello"},
					options:{property:"str", minimum:6},
					passes:false
				},
				{
					object:{str:"Hello"},
					options:{property:"str", maximum:5},
					passes:true
				},
				{
					object:{str:"Hello"},
					options:{property:"str", maximum:4},
					passes:false
				},
				{
					object:{str:"Hello"},
					options:{property:"str", between:"0..5"},
					passes:true
				},
				{
					object:{str:"Hello"},
					options:{property:"str", between:"1..5"},
					passes:true
				},
				{
					object:{str:"Hello"},
					options:{property:"str", between:"0..4"},
					passes:false
				},
				{
					object:{str:"Hello"},
					options:{property:"str", between:"0..6"},
					passes:true
				},
				{
					object:{str:"Hello"},
					options:{property:"str", length:"5"},
					passes:true
				},
				{
					object:{str:"Hello"},
					options:{property:"str", length:"4"},
					passes:false
				}
			];
			
			for (var i:int = 0; i < tests.length; i++) {
				var result:Array = new LengthValidator(tests[i].options).validate(tests[i].object);
				assertThat("validation failed for test " + i, result.length == 0, equalTo(tests[i].passes));
			}
		}
	}
}