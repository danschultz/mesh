package mesh
{
	import mesh.core.object.copy;
	import mesh.model.validators.PresenceValidator;
	
	import mx.collections.IList;
	
	[RemoteClass(alias="mesh.Customer")]
	
	public class Customer extends Person
	{
		public static var validate:Object = 
		{
			address: [{validator:PresenceValidator}]
		};
		
		[Bindable] public var address:Address;
		[Bindable] public var accountId:int;
		[Bindable] public var account:Account;
		[Bindable] public var orders:IList;
		
		public function Customer(properties:Object = null)
		{
			super(properties);
			
			hasOne("account", {inverse:"customer", isMaster:true});
			hasMany("orders", {inverse:"customer", isMaster:true});
		}
		
		override public function toObject(options:Object = null):Object
		{
			var result:Object = super.toObject();
			copy(this, result, {includes:["address", "accountId"]});
			return result;
		}
	}
}