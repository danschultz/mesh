package mesh.associations
{
	import mesh.Entity;
	import mesh.core.inflection.camelize;
	import mesh.core.reflection.className;
	
	/**
	 * An association that defines a one-to-one relationship with another model. This
	 * relationship indicates that each instance of a model contains an instance of
	 * another model.
	 * 
	 * @author Dan Schultz
	 */
	public class HasOneDefinition extends AssociationDefinition
	{
		/**
		 * @copy Relationship#Relationship()
		 */
		public function HasOneDefinition(owner:Class, property:String, target:Class, options:Object)
		{
			super(owner, property, target, options);
		}
		
		/**
		 * @inheritDoc
		 */
		override public function createProxy(entity:Entity):*
		{
			return new HasOneAssociation(entity, this);
		}
	}
}