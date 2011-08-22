package mesh.model.associations
{
	import mesh.model.Entity;
	
	public class HasManyAssociation extends AssociationCollection
	{
		/**
		 * @copy AssociationCollection#AssociationCollection()
		 */
		public function HasManyAssociation(source:Entity, property:String, options:Object = null)
		{
			super(source, property, options);
		}
	}
}