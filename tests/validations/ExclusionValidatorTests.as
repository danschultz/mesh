package validations
{
	import mesh.validators.Errors;
	import mesh.validators.ExclusionValidator;
	
	import mx.collections.ArrayCollection;
	
	import org.flexunit.assertThat;
	import org.hamcrest.object.equalTo;
	
	import reflection.inspect;

	public class ExclusionValidatorTests
	{
		[Test]
		public function testValidate():void
		{
			var tests:Array = [
				{
					object:{str:"Hello", errors:new Errors(null)},
					options:{property:"str", within:["Hello", "Hi"]},
					passes:false
				},
				{
					object:{str:"Hello", errors:new Errors(null)},
					options:{property:"str", within:["Hi"]},
					passes:true
				},
				{
					object:{str:"Hello", errors:new Errors(null)},
					options:{property:"str", within:new ArrayCollection(["Hello", "Hi"])},
					passes:false
				},
				{
					object:{str:"Hello", errors:new Errors(null)},
					options:{property:"str", within:new ArrayCollection(["a", "b", "c"])},
					passes:true
				}
			];
			
			for each (var test:Object in tests) {
				new ExclusionValidator(test.options).validate(test.object);
				assertThat("validation failed for test " + inspect(test.options), test.object.errors.length == 0, equalTo(test.passes));
			}
		}
	}
}