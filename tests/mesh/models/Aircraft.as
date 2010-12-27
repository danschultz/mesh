package mesh.models
{
	import mesh.Entity;
	
	public class Aircraft extends Entity
	{
		public function Aircraft()
		{
			super();
			
			Manufacturer;
		}
		
		[HasMany(type="mesh.models.Manufacturer", lazy="true")]
		public function get manufacturers():Object
		{
			return association("manufacturers");
		}
	}
}