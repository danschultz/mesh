package mesh.models
{
	import mesh.Entity;
	import mesh.adaptors.InMemoryAdaptor;
	
	[Ignore(properties="ignoredProperty2, ignoredProperty3")]
	[BelongsTo(type="mesh.models.Customer")]
	public dynamic class Account extends Entity
	{
		[ServiceAdaptor]
		public static var adaptor:InMemoryAdaptor;
		
		[Bindable]
		public var number:String;
		
		[Ignore]
		[Bindable]
		public var ignoredProperty1:String;
		
		[Bindable]
		public var ignoredProperty2:String;
		
		[Bindable]
		public var ignoredProperty3:String;
		
		public function Account()
		{
			super();
		}
	}
}