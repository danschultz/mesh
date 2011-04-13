package mesh.models
{
	import flash.utils.flash_proxy;
	
	import mesh.Entity;
	import mesh.associations.HasOneAssociation;
	
	public class Order extends Entity
	{
		[Bindable] public var shippingAddress:Address;
		[Bindable] public var total:Number;
		
		public function Order()
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
		
		flash_proxy function get customer():Customer
		{
			return customer.flash_proxy::object;
		}
		flash_proxy function set customer(value:Customer):void
		{
			customer.flash_proxy::object = value;
		}
	}
}