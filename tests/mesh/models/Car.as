package mesh.models
{
	import mesh.Entity;
	import mesh.adaptors.InMemoryAdaptor;
	
	public dynamic class Car extends Entity
	{
		[ServiceAdaptor]
		public static var adaptor:InMemoryAdaptor;
		
		[Bindable]
		public var make:String;
		
		[Bindable]
		public var model:String;
		
		[Bindable]
		public var year:String;
		
		[Bindable]
		public var msrp:Number;
		
		public function Car()
		{
			super();
		}
	}
}