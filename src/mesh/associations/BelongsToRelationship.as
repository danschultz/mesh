package mesh.associations
{
	import mesh.core.inflection.camelize;
	
	import mesh.core.reflection.className;

	/**
	 * An association that defines that an entity belongs to an instance of another entity.
	 * 
	 * @author Dan Schultz
	 */
	public class BelongsToRelationship extends HasOneRelationship
	{
		/**
		 * @copy Relationship#Relationship()
		 */
		public function BelongsToRelationship(owner:Class, property:String, target:Class, options:Object)
		{
			super(owner, property, target, options);
		}
	}
}