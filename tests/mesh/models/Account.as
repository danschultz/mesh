package mesh.models
{
	import mesh.Entity;
	
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