package mesh
{
	import flash.utils.flash_proxy;
	
	import mesh.core.object.copy;
	import mesh.model.associations.HasManyAssociation;
	import mesh.model.associations.HasOneAssociation;
	import mesh.model.validators.PresenceValidator;
	import mesh.services.TestService;
	
	public class Customer extends Person
	{
		Mesh.services.map(Customer, new TestService(Customer));
		
		public static var validate:Object = 
		{
			address: [{validator:PresenceValidator}]
		};
		
		[Bindable] public var address:Address;
		[Bindable] public var accountId:int;
		
		public function Customer(properties:Object = null)
		{
			super(properties);
		}
		
		override public function translateTo():*
		{
			var result:Object = super.translateTo();
			copy(this, result, {includes:["address", "accountId"]});
			return result;
		}
		
		public function get account():HasOneAssociation
		{
			return hasOne("account", Account, {foreignKey:"accountId", autoSave:true});
		}
		public function set account(value:HasOneAssociation):void
		{
			account.flash_proxy::object = value;
		}
		
		public function get orders():HasManyAssociation
		{
			return hasMany("orders", Order, {inverse:"customer", autoSave:true});
		}
		public function set orders(value:HasManyAssociation):void
		{
			orders.flash_proxy::object = value;
		}
	}
}