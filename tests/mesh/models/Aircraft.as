package mesh.models
{
	import mesh.Entity;
	
	import mx.collections.IList;
	
	[RemoteClass(alias="mesh.models.Aircraft")]
	public class Aircraft extends Entity
	{
		Manufacturer;
		
		public function Aircraft()
		{
			super();
		}
		
		[HasMany(type="mesh.models.Manufacturer", lazy="true")]
		public function get manufacturers():*
		{
			return association("manufacturers").target;
		}
		public function set manufacturers(value:*):void
		{
			association("manufacturers").target = value;
		}
		
		[HasOne(type="mesh.models.Customer", lazy="true")]
		public function get owner():*
		{
			return association("owner");
		}
		public function set owner(value:*):void
		{
			association("owner").target = value;
		}
	}
}