package mesh.models
{
	import mesh.Entity;
	import mesh.adaptors.InMemoryAdaptor;
	
	public class Car extends Entity
	{
		[ServiceAdaptor]
		public static var adaptor:InMemoryAdaptor;
		
		[Bindable]
		public var msrp:Number;
		
		public function Car()
		{
			super();
		}
	}
}