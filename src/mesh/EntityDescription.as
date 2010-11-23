package mesh
{
	import collections.HashSet;
	import collections.Set;
	
	import flash.utils.describeType;
	import flash.utils.getDefinitionByName;

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
		 * Generates an entity description from the given entity class.
		 * 
		 * @param entity The entity to generate the description from.
		 * @return A new entity description.
		 */
		public static function fromEntity(entity:Class):EntityDescription
		{
			var classInfo:XML = describeType(entity);
			var relationships:HashSet = new HashSet();
			
			var relationsshipsXML:XMLList = classInfo..metadata.(@name == "Relationship");
			for each (var relationshipXML:XML in relationsshipsXML) {
				var to:XMLList = relationshipXML.arg.(@key == "to");
				var deletionRule:XMLList = relationshipXML.arg.(@key == "deletionRule");
				
				relationships.add( new Relationship(entity, 
													relationshipXML.parent().@name, 
													getDefinitionByName(to.length() > 0 ? to.@value : relationshipXML.parent().@type) as Class, 
													deletionRule.length() > 0 ? deletionRule.@value : Relationship.NOTHING) );
			}
			
			return new EntityDescription(entity, relationships);
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