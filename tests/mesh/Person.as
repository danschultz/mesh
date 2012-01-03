package mesh
{
	import mesh.model.Entity;
	import mesh.model.validators.NumericValidator;
	import mesh.model.validators.PresenceValidator;
	
	public class Person extends Entity
	{
		public static var validate:Object = 
		{
			name: [{validator:PresenceValidator}],
			age: [{validator:NumericValidator, greaterThan:0, integer:true}]
		};
		
		[Bindable] public var age:Number;
		[Bindable] public var name:Name;
		
		public function Person(properties:Object = null)
		{
			super(properties);
		}
	}
}