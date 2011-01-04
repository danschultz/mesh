package mesh.associations
{
	import inflections.camelize;
	
	import reflection.className;

	/**
	 * An association that defines that an entity belongs to an instance of another entity.
	 * 
	 * @author Dan Schultz
	 */
	public class BelongsToRelationship extends Relationship
	{
		/**
		 * @copy Relationship#Relationship()
		 */
		public function BelongsToRelationship(owner:Class, property:String, target:Class, options:Object)
		{
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