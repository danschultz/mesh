package mesh
{
	import mesh.model.associations.HasManyAssociation;
	import mesh.model.store.Store;
	
	import mx.collections.IList;

	public class Customer extends Person
	{
		[Bindable] public var account:Account;
		[Bindable] public var accountId:int;
		[Bindable] public var orders:HasManyAssociation;
		
		public function Customer(properties:Object=null)
		{
			super(properties);
			
			hasOne("account");
			hasMany("orders", function(store:Store):IList
			{
				return store.query(Order).where({customerId:id});
			}, {inverse:"customer"});
		}
	}
}