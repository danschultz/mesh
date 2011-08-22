package mesh.model.associations
{
	import mesh.model.Entity;
	
	public class HasAssociation extends Association
	{
		/**
		 * @copy AssociationProxy#AssociationProxy()
		 */
		public function HasAssociation(owner:Entity, property:String, options:Object = null)
		{
			super(owner, property, options);
		}
	}
}