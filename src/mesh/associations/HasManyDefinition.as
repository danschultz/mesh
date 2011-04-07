package mesh.associations
{
	import mesh.Entity;
	import mesh.core.inflection.camelize;
	import mesh.core.inflection.pluralize;
	import mesh.core.reflection.className;

	/**
	 * An association that defines a one-to-many relationship with another model. This
	 * relationship indicates that each instance of a model contains zero or many 
	 * instances of another model.
	 * 
	 * @author Dan Schultz
	 */
	public class HasManyDefinition extends AssociationDefinition
	{
		/**
		 * @copy Relationship#Relationship()
		 */
		public function HasManyDefinition(owner:Class, property:String, target:Class, options:Object)
		{
			if (property == null || property.length == 0) {
				property = camelize(pluralize(className(target)), false);
			}
			
			super(owner, property, target, options);
		}
		
		/**
		 * @inheritDoc
		 */
		override public function createProxy(entity:Entity):*
		{
			return new HasManyAssociation(entity, this);
		}
	}
}