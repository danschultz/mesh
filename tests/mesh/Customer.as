package mesh
{
	import flash.utils.flash_proxy;
	
	import mesh.model.associations.HasManyAssociation;
	import mesh.model.associations.HasOneAssociation;
	import mesh.core.object.copy;
	import mesh.services.Request;
	import mesh.services.TestService;
	import mesh.model.validators.PresenceValidator;
	
	public class Customer extends Person
	{
		Mesh.services.map(Customer, new TestService(Customer));
		
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
			return hasMany("orders", Order, {
				inverse:"customer",
				loadRequest:function():Request
				{
					return Mesh.services.serviceFor(Order).belongingTo(this);
				}
			});
		}
		public function set orders(value:HasManyAssociation):void
		{
			orders.flash_proxy::object = value;
		}
	}
}