package mesh
{
	import flash.utils.flash_proxy;
	
	import mesh.core.object.copy;
	import mesh.model.associations.HasManyAssociation;
	import mesh.model.associations.HasOneAssociation;
	import mesh.model.validators.PresenceValidator;
	import mesh.services.TestService;
	
	use namespace flash_proxy;
	
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
		
		override public function serialize():*
		{
			var result:Object = super.serialize();
			copy(this, result, {includes:["address", "accountId"]});
			return result;
		}
		
		public function get account():HasOneAssociation
		{
			return hasOne("account", null, {foreignKey:"accountId", autoSave:true});
		}
		
		public function get orders():HasManyAssociation
		{
			return hasMany("orders", null, {inverse:"customer", autoSave:true});
		}
	}
}