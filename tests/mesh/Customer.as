package mesh
{
	import mesh.model.associations.HasManyAssociation;
	
	[Bindable]
	public class Customer extends Person
	{
		[HasOne]
		public var account:Account;
		
		public var accountId:int;
		
		[HasMany(inverse="customer", recordType="mesh.Order", isMaster="true")]
		public var orders:HasManyAssociation;
		
		public function Customer(properties:Object=null)
		{
			super(properties);
		}
	}
}