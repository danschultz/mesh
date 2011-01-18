package mesh.associations
{
	import mesh.core.inflection.camelize;
	
	import mesh.core.reflection.className;
	
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
			if (property == null || property.length == 0) {
				property = camelize(className(target), false);
			}
			
			super(owner, property, target, options);
		}
		
		/**
		 * The name of the foreign key property.
		 */
		public function get foreignKey():String
		{
			if (options.hasOwnProperty("foreignKey")) {
				return options.foreignKey;
			}
			return property + "Id";
		}
		
		/**
		 * @inheritDoc
		 */
		override public function get properties():Array
		{
			return super.properties.concat(foreignKey);
		}
	}
}