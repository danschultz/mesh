package mesh.models
{
	import flash.utils.flash_proxy;
	
	import mesh.associations.HasManyAssociation;
	import mesh.associations.HasOneAssociation;
	import mesh.validators.LengthValidator;
	import mesh.validators.PresenceValidator;
	
	public class Customer extends Person
	{
		public static var validate:Object = 
		{
			addressStreet: [{validator:PresenceValidator}, {validator:LengthValidator, minimum:2}],
			addressCity: [{validator:PresenceValidator}, {validator:LengthValidator, minimum:2}]
		};
		
		[Bindable] public var address:Address;
		
		public function Customer()
		{
			super();
		}
		
		public function get account():HasOneAssociation
		{
			return hasOne("account", Account);
		}
		public function set account(value:HasOneAssociation):void
		{
			account.flash_proxy::object = value;
		}
		
		public function get orders():HasManyAssociation
		{
			return hasMany("orders", Order);
		}
		public function set orders(value:HasManyAssociation):void
		{
			orders.flash_proxy::object = value;
		}
	}
}