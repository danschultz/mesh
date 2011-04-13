package mesh.models
{
	import mesh.Entity;
	import mesh.validators.LengthValidator;
	import mesh.validators.NumericValidator;
	import mesh.validators.PresenceValidator;
	
	public class Person extends Entity
	{
		public static var validate:Object = 
		{
			firstName: [{validator:PresenceValidator}, {validator:LengthValidator, minimum:2}],
			lastName: [{validator:PresenceValidator}, {validator:LengthValidator, minimum:2}],
			age: [{validator:NumericValidator, greaterThan:0, integer:true}]
		};
		
		[Bindable] public var age:Number;
		[Bindable] public var name:Name;
		
		public function Person()
		{
			super();
		}
	}
}