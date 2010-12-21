package mesh.models
{
	import mesh.Entity;
	import mesh.associations.AssociationCollection;
	
	[TranslateTo(type="mesh.models.AircraftVO")]
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