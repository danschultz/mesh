package mesh.model.associations
{
	import mesh.model.Record;
	
	public class HasManyAssociation extends AssociationCollection
	{
		/**
		 * @copy AssociationCollection#AssociationCollection()
		 */
		public function HasManyAssociation(source:Record, property:String, query:Function, options:Object = null)
		{
			super(source, property, query, options);
		}
	}
}