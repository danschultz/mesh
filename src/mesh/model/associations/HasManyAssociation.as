package mesh.model.associations
{
	import mesh.model.Record;
	
	public class HasManyAssociation extends AssociationCollection
	{
		/**
		 * @copy AssociationCollection#AssociationCollection()
		 */
		public function HasManyAssociation(source:Record, property:String, options:Object = null)
		{
			super(source, property, options);
		}
	}
}