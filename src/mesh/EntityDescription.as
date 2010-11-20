package mesh
{
	import collections.Set;

	/**
	 * A class that describes the relationships for an entity and how it's persisted.
	 * 
	 * @author Dan Schultz
	 */
	public class EntityDescription
	{
		/**
		 * Constructor.
		 * 
		 * @param entity The entity being described.
		 * @param relationships The <code>Relationship</code>s for this entity.
		 * @param strategy How the entity is stored.
		 */
		public function EntityDescription(entity:Class, relationships:Set)
		{
			_entity = entity;
			_relationships = relationships;
		}
		
		/**
		 * Checks if two descriptions are equal.
		 * 
		 * @param description The description to check.
		 * @return <code>true</code> if the descriptions are equal.
		 */
		public function equals(description:EntityDescription):Boolean
		{
			return description != null && 
				   entity == description.entity &&
				   relationships.equals(description.relationships);
		}
		
		/**
		 * Returns the entity class of the description.
		 * 
		 * @return The entity class.
		 */
		public function hashCode():Object
		{
			return entity;
		}
		
		private var _entity:Class;
		/**
		 * The entity that this object is describing.
		 */
		public function get entity():Class
		{
			return _entity;
		}
		
		private var _relationships:Set;
		/**
		 * The <code>Relationship</code>s for this entity.
		 */
		public function get relationships():Set
		{
			return _relationships;
		}
	}
}