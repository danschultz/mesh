package mesh.model.associations
{
	import mesh.model.Record;
	
	public class HasOneAssociation extends HasAssociation
	{
		/**
		 * @copy HasAssociation#HasAssociation()
		 */
		public function HasOneAssociation(owner:Record, property:String, options:Object = null)
		{
			super(owner, property, options);
		}
	}
}