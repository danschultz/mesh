package mesh.model.validators
{
	
	import org.flexunit.assertThat;
	import org.hamcrest.object.equalTo;
	
	import mesh.core.object.inspect;

	public class FormatValidatorTests
	{
		[Test]
		public function testValidate():void
		{
			var tests:Array = [
				{
					object:{str:"Hello123", errors:new Errors(null)},
					options:{property:"str", format:/\A[a-zA-Z]+\z/},
					passes:false
				},
				{
					object:{str:"Hello", errors:new Errors(null)},
					options:{property:"str", format:/\A[a-zA-Z]+\z/},
					passes:true
				}
			];
			
			for each (var test:Object in tests) {
				new FormatValidator(test.options).validate(test.object);
				assertThat("validation failed for test " + inspect(test.options), test.object.errors.length == 0, equalTo(test.passes));
			}
		}
	}
}