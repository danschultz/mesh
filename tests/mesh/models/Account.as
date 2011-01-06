package mesh.models
{
	import mesh.Entity;
	
	[BelongsTo(type="mesh.models.Customer")]
	public dynamic class Account extends Entity
	{
		[Bindable]
		public var number:String;
		
		public function Account()
		{
			super();
		}
	}
}