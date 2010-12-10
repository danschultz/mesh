package mesh
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
		 * @inheritDoc
		 */
		override public function createProxy(entity:Entity):AssociationProxy
		{
			return new AssociationProxy(entity, this);
		}
		
		/**
		 * The name of the foreign key property.
		 */
		public function get foreignKey():String
		{
			if (options.hasOwnProperty("foreignKey")) {
				return options.foreignKey;
			}
			return camelize(className(target), false) + "Id";
		}
	}
}