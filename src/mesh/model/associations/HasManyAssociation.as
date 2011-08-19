package mesh.model.associations
{
	import mesh.model.Entity;
	import mesh.model.store.Query;
	
	public class HasManyAssociation extends AssociationCollection
	{
		/**
		 * @copy AssociationCollection#AssociationCollection()
		 */
		public function HasManyAssociation(source:Entity, query:Query, options:Object = null)
		{
			super(source, query, options);
		}
	}
}