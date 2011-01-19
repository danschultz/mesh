package mesh.models
{
	import mesh.Entity;
	import mesh.adaptors.InMemoryAdaptor;
	
	[BelongsTo(type="mesh.models.Customer")]
	public dynamic class Account extends Entity
	{
		[ServiceAdaptor]
		public static var adaptor:InMemoryAdaptor;
		
		[Bindable]
		public var number:String;
		
		public function Account()
		{
			super();
		}
	}
}