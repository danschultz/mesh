package mesh.associations
{
	import inflections.camelize;
	import inflections.pluralize;
	
	import mesh.Entity;
	
	import reflection.className;

	/**
	 * An association that defines a one-to-many relationship with another model. This
	 * relationship indicates that each instance of a model contains zero or many 
	 * instances of another model.
	 * 
	 * @author Dan Schultz
	 */
	public class HasManyRelationship extends Relationship
	{
		/**
		 * @copy Relationship#Relationship()
		 */
		public function HasManyRelationship(owner:Class, property:String, target:Class, options:Object)
		{
			if (property == null || property.length == 0) {
				property = camelize(pluralize(className(target)), false);
			}
			
			super(owner, property, target, options);
		}
	}
}