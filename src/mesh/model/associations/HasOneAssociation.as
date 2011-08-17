package mesh.model.associations
{
	import mesh.model.Entity;
	import mesh.model.query.Query;
	
	public class HasOneAssociation extends HasAssociation
	{
		/**
		 * @copy HasAssociation#HasAssociation()
		 */
		public function HasOneAssociation(owner:Entity, query:Query, options:Object = null)
		{
			super(owner, query, options);
		}
	}
}