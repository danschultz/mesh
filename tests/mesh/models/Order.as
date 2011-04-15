package mesh.models
{
	import flash.utils.flash_proxy;
	
	import mesh.Entity;
	import mesh.associations.HasOneAssociation;
	
	public class Order extends Entity
	{
		[Bindable] public var shippingAddress:Address;
		[Bindable] public var total:Number;
		
		public function Order(properties:Object = null)
		{
			super(properties);
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