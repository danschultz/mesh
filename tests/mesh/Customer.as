package mesh
{
	import mesh.core.object.merge;
	import mesh.model.validators.PresenceValidator;
	
	import mx.collections.ArrayList;
	import mx.collections.IList;
	
	[RemoteClass(alias="mesh.Customer")]
	
	public class Customer extends Person
	{
		public static var validate:Object = 
		{
			address: [{validator:PresenceValidator}]
		};
		
		[Bindable] public var address:Address;
		public var accountId:int;
		[Bindable] public var account:Account;
		[Bindable] public var orders:IList;
		
		public function Customer(properties:Object = null)
		{
			super(properties);
			
			hasOne("account", {inverse:"customer", isMaster:true, foreignKey:"accountId"});
			hasMany("orders", {inverse:"customer", isMaster:true});
		}
		
		override public function fromObject(object:Object):void
		{
			super.fromObject(object);
			account = object.account != null ? new Account(object.account) : null;
			address = object.address != null ? new Address(object.address.street, object.address.city) : null;
			orders = object.orders != null ? new ArrayList(object.orders.map(function(order:Object, ...args):Order
			{
				return new Order(order);
			})) : null;
		}
		
		override protected function get serializableOptions():Object
		{
			var inherited:Object = super.serializableOptions;
			inherited.includes = merge(inherited.includes, {address:true, account:true, orders:true});
			return inherited;
		}
	}
}