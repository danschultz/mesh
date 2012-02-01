package mesh
{
	import mesh.model.associations.HasManyAssociation;
	import mesh.model.store.Store;
	
	import mx.collections.IList;
	
	[Bindable]
	public class Customer extends Person
	{
		[HasOne]
		public var account:Account;
		
		public var accountId:int;
		
		[HasMany(inverse="customer")]
		public var orders:HasManyAssociation;
		
		public function Customer(properties:Object=null)
		{
			super(properties);
			
			orders.query = function(store:Store):IList
			{
				return store.query(Order).where({customerId:id});
			};
		}
	}
}