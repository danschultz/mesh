package mesh
{
	import flash.utils.flash_proxy;
	
	import mesh.core.object.copy;
	import mesh.model.Entity;
	import mesh.model.associations.HasOneAssociation;
	import mesh.services.TestService;
	
	use namespace flash_proxy;
	
	public class Account extends Entity
	{
		Mesh.services.map(Account, new TestService(Account));
		
		[Bindable] public var number:String;
		
		public function Account()
		{
			super();
		}
		
		override public function deserialize(object:Object):void
		{
			copy(object, this);
		}
		
		override public function serialize():*
		{
			var object:Object = {};
			copy(this, object, {includes:["id", "number"]});
			return object;
		}
		
		public function get customer():HasOneAssociation
		{
			return hasOne("customer", null);
		}
		public function set customer(value:HasOneAssociation):void
		{
			customer.object = value;
		}
	}
}