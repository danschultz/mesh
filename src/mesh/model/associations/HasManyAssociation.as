package mesh.model.associations
{
	import mesh.model.Entity;
	
	public class HasManyAssociation extends AssociationCollection
	{
		/**
		 * @copy AssociationCollection#AssociationCollection()
		 */
		public function HasManyAssociation(source:Entity, options:Object = null)
		{
			super(source, options);
		}
	}
}