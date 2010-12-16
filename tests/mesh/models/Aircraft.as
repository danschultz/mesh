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
		
		private var _manufaturers:AssociationCollection;
		[HasMany(type="mesh.models.Manufacturer", lazy="true")]
		public function get manufacturers():AssociationCollection
		{
			if (_manufaturers == null) {
				_manufaturers = new AssociationCollection(this, descriptor.getRelationshipForProperty("manufacturers"));
			}
			return _manufaturers;
		}
	}
}