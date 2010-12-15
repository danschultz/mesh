package mesh.models
{
	import mesh.Entity;
	import mesh.adaptors.InMemoryAdaptor;
	
	public class Car extends Entity
	{
		[ServiceAdaptor]
		public static var adaptor:InMemoryAdaptor;
		
		public function Car()
		{
			super();
		}
	}
}