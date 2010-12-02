package mesh
{
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
			super(owner, property, target, options);
		}
	}
}