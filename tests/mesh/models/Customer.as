package mesh.models
{
	import flash.utils.flash_proxy;
	
	import mesh.associations.HasManyAssociation;
	import mesh.associations.HasOneAssociation;
	import mesh.core.object.copy;
	import mesh.validators.PresenceValidator;
	
	public class Customer extends Person
	{
		public static var validate:Object = 
		{
			address: [{validator:PresenceValidator}]
		};
		
		[Bindable] public var address:Address;
		
		public function Customer(properties:Object = null)
		{
			super(properties);
		}
		
		override public function translateTo():*
		{
			var result:Object = super.translateTo();
			copy(this, result, {includes:["address"]});
			return result;
		}
		
		public var accountId:int;
		
		public function get account():HasOneAssociation
		{
			return hasOne("account", Account, {foreignKey:"accountId"});
		}
		public function set account(value:HasOneAssociation):void
		{
			account.flash_proxy::object = value;
		}
		
		public function get orders():HasManyAssociation
		{
			return hasMany("orders", Order, {inverse:"customer"});
		}
		public function set orders(value:HasManyAssociation):void
		{
			orders.flash_proxy::object = value;
		}
	}
}