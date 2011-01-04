package mesh.models
{
	import mesh.Entity;
	
	[ComposedOf(property="location", type="mesh.models.Coordinate", mapping="latitude, longitude", bindable="false")]
	
	[BelongsTo(property="significantOther", type="mesh.models.Person")]
	
	public dynamic class Person extends Entity
	{
		public function Person()
		{
			super();
		}
		
		private var _fullName:Name;
		[Bindable]
		[ComposedOf(mapping="firstName,lastName")]
		[Validate(properties="firstName,lastName", validator="mesh.validators.LengthValidator", minimum="1")]
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
		[Validate(validator="mesh.validators.NumericValidator", between="1..120")]
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