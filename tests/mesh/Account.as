package mesh
{
	import flash.utils.flash_proxy;
	
	import mesh.model.Entity;
	import mesh.model.associations.HasOneAssociation;
	
	public class Account extends Entity
	{
		[Bindable] public var number:String;
		
		public function Account()
		{
			super();
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