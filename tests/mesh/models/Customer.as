package mesh.models
{
	import mesh.AssociationProxy;
	import mesh.Entity;
	
	[Validate(properties="addressStreet,addressCity", validator="validations.LengthValidator", minimum="1")]
	[ComposedOf(property="address", type="mesh.models.Address", prefix="address", mapping="street,city")]
	
	[HasMany(type="mesh.models.Order", property="orders")]
	[HasMany(type="mesh.models.Car")]
	public dynamic class Customer extends Entity
	{
		public function Customer()
		{
			super();
			
			Order;
			Car;
		}
		
		private var _fullName:Name;
		[Bindable]
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
		
		private var _primaryCar:AssociationProxy;
		[HasOne(type="mesh.models.Car")]
		public function get primaryCar():AssociationProxy
		{
			return _primaryCar;
		}
		public function set primaryCar(value:AssociationProxy):void
		{
			_primaryCar = value;
		}
		
		public function get associations():Array
		{
			return relationshipsForEntity(this).values();
		}
		
		public function get validations():Array
		{
			return validators();
		}
	}
}