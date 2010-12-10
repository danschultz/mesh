package mesh.associations
{
	import mesh.Entity;

	/**
	 * An association that defines a one-to-one relationship with another model. This
	 * relationship indicates that each instance of a model contains an instance of
	 * another model.
	 * 
	 * @author Dan Schultz
	 */
	public class HasOneRelationship extends Relationship
	{
		/**
		 * @copy Relationship#Relationship()
		 */
		public function HasOneRelationship(owner:Class, property:String, target:Class, options:Object)
		{
			super(owner, property, target, options);
		}
		
		/**
		 * @inheritDoc
		 */
		override public function createProxy(entity:Entity):AssociationProxy
		{
			return new AssociationProxy(entity, this);
		}
	}
}