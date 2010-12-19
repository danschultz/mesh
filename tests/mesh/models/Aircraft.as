package mesh.models
{
	import mesh.Entity;
	import mesh.associations.AssociationCollection;
	
	public class Aircraft extends Entity
	{
		public function Aircraft()
		{
			super();
			
			Manufacturer;
		}
		
		[HasMany(type="mesh.models.Manufacturer", lazy="true")]
		public function get manufacturers():AssociationCollection
		{
			return AssociationCollection( associationProxyFor("manufacturers") );
		}
	}
}