package mesh.models
{
	import mesh.Entity;
	
	[ServiceAdaptor(type="mesh.adaptors.InMemoryAdaptor")]
	public class Car extends Entity
	{
		public function Car()
		{
			super();
		}
	}
}