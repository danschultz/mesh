package mesh.validators
{
	
	import mx.collections.ArrayCollection;
	
	import org.flexunit.assertThat;
	import org.hamcrest.object.equalTo;
	
	import mesh.core.object.inspect;

	public class InclusionValidatorTests
	{
		[Test]
		public function testValidate():void
		{
			var tests:Array = [
				{
					object:{str:"Hello", errors:new Errors(null)},
					options:{property:"str", within:["Hello", "Hi"]},
					passes:true
				},
				{
					object:{str:"Hello", errors:new Errors(null)},
					options:{property:"str", within:["Hi"]},
					passes:false
				},
				{
					object:{str:"Hello", errors:new Errors(null)},
					options:{property:"str", within:new ArrayCollection(["Hello", "Hi"])},
					passes:true
				},
				{
					object:{str:"Hello", errors:new Errors(null)},
					options:{property:"str", within:new ArrayCollection(["a", "b"])},
					passes:false
				}
			];
			
			for each (var test:Object in tests) {
				new InclusionValidator(test.options).validate(test.object);
				assertThat("validation failed for test " + inspect(test.options), test.object.errors.length == 0, equalTo(test.passes));
			}
		}
	}
}