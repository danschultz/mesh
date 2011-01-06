package mesh.models
{
	import mesh.Entity;
	
	[RemoteClass(alias="mesh.models.Manufacturer")]
	[BelongsTo(type="mesh.models.Aircraft")]
	public class Manufacturer extends Entity
	{
		[Bindable]
		public var name:String;
		
		public function Manufacturer()
		{
			super();
		}
	}
}