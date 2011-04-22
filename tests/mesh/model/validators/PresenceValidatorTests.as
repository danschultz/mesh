package mesh.model.validators
{
	
	import org.flexunit.assertThat;
	import org.hamcrest.object.equalTo;
	
	import mesh.core.object.inspect;

	public class PresenceValidatorTests
	{
		[Test]
		public function testValidate():void
		{
			var tests:Array = [
				{
					object:{str:"hello", errors:new Errors(null)},
					options:{property:"str"},
					passes:true
				},
				{
					object:{str:"", errors:new Errors(null)},
					options:{property:"str"},
					passes:false
				},
				{
					object:{str:" ", errors:new Errors(null)},
					options:{property:"str"},
					passes:false
				},
				{
					object:{num:0, errors:new Errors(null)},
					options:{property:"num"},
					passes:true
				},
				{
					object:{num:NaN, errors:new Errors(null)},
					options:{property:"num"},
					passes:false
				},
				{
					object:{elements:[1], errors:new Errors(null)},
					options:{property:"elements"},
					passes:true
				},
				{
					object:{elements:[], errors:new Errors(null)},
					options:{property:"elements"},
					passes:false
				},
				{
					object:{includes:false, errors:new Errors(null)},
					options:{property:"includes"},
					passes:true
				}
			];
			
			for each (var test:Object in tests) {
				new PresenceValidator(test.options).validate(test.object);
				assertThat("validation failed for test " + inspect(test.options), test.object.errors.length == 0, equalTo(test.passes));
			}
		}
	}
}