package mesh
{
	import flash.utils.flash_proxy;
	
	import mesh.core.object.copy;
	import mesh.model.Entity;
	import mesh.model.associations.HasOneAssociation;
	import mesh.services.TestService;
	
	public class Account extends Entity
	{
		Mesh.services.map(Account, new TestService(Account));
		
		[Bindable] public var number:String;
		
		public function Account()
		{
			super();
		}
		
		override public function translateFrom(object:Object):void
		{
			copy(object, this);
		}
		
		override public function translateTo():*
		{
			var object:Object = {};
			copy(this, object, {includes:["id", "number"]});
			return object;
		}
		
		public function get customer():HasOneAssociation
		{
			return hasOne("customer", Customer);
		}
		public function set customer(value:HasOneAssociation):void
		{
			customer.flash_proxy::object = value;
		}
	}
}