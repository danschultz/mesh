package mesh.models
{
	import mesh.Entity;
	import mesh.validators.LengthValidator;
	import mesh.validators.NumericValidator;
	import mesh.validators.PresenceValidator;
	
	[ComposedOf(property="location", type="mesh.models.Coordinate", mapping="latitude, longitude", bindable="false")]
	
	[HasOne(property="partner", type="mesh.models.Person")]
	
	public dynamic class Person extends Entity
	{
		public static var validate:Object = 
		{
			firstName: [{validator:PresenceValidator}, {validator:LengthValidator, minimum:2}],
			lastName: [{validator:PresenceValidator}, {validator:LengthValidator, minimum:2}],
			age: [{validator:NumericValidator, greaterThan:0, integer:true}]
		};
		
		public function Person()
		{
			super();
		}
		
		private var _fullName:Name;
		[Bindable]
		[ComposedOf(mapping="firstName,lastName")]
		public function get fullName():Name
		{
			return _fullName;
		}
		public function set fullName(value:Name):void
		{
			_fullName = value;
		}
		
		private var _age:Number;
		[Bindable]
		public function get age():Number
		{
			return _age;
		}
		public function set age(value:Number):void
		{
			_age = value;
		}
	}
}