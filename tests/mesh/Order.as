package mesh
{
	import flash.utils.flash_proxy;
	
	import mesh.core.object.copy;
	import mesh.model.Entity;
	import mesh.model.associations.HasOneAssociation;
	import mesh.services.TestService;
	
	use namespace flash_proxy;
	
	public class Order extends Entity
	{
		Mesh.services.map(Order, new TestService(Order, function(belongingTo:Entity, entities:Array):Array
		{
			return entities.filter(function(entity:Object, ...args):Boolean
			{
				if (belongingTo is Customer) {
					return entity.customerId == belongingTo.id;
				}
				return false;
			});
		}));
		
		[Bindable] public var shippingAddress:Address;
		[Bindable] public var total:Number;
		
		public function Order(properties:Object = null)
		{
			super(properties);
		}
		
		override public function translateFrom(object:Object):void
		{
			copy(object, this);
		}
		
		override public function translateTo():*
		{
			var object:Object = {};
			copy(this, object, {includes:["id", "customerId", "shippingAddress", "total"]});
			return object;
		}
		
		public var customerId:int;
		
		public function get customer():HasOneAssociation
		{
			return hasOne("customer", Customer, {foreignKey:"customerId"});
		}
		public function set customer(value:HasOneAssociation):void
		{
			customer.object = value;
		}
	}
}