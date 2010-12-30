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
		public function get manufacturers():IList
		{
			return association("manufacturers").target;
		}
		public function set manufacturers(value:IList):void
		{
			association("manufacturers").target = value;
		}
		
		[HasOne(type="mesh.models.Customer", lazy="true")]
		public function get owner():Customer
		{
			return association("owner").target;
		}
		public function set owner(value:Customer):void
		{
			association("owner").target = value;
		}
	}
}