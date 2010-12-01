package mesh.models
{
	import mesh.Entity;
	
	[Validate(properties="addressStreet,addressCity", validator="validations.LengthValidator", minimum="1")]
	[ComposedOf(property="address", type="mesh.models.Address", prefix="address", mapping="street,city")]
	public dynamic class Customer extends Entity
	{
		public function Customer()
		{
			super();
		}
		
		private var _fullName:Name;
		[ComposedOf(mapping="firstName,lastName")]
		[Validate(properties="firstName,lastName", validator="validations.LengthValidator", minimum="1")]
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
		[Validate(validator="validations.NumericValidator", between="1..120")]
		public function get age():Number
		{
			return _age;
		}
		public function set age(value:Number):void
		{
			_age = value;
		}
		
		public function get validations():Array
		{
			return validators();
		}
	}
}