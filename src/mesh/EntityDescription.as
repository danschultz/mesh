package mesh
{
	import collections.HashSet;
	import collections.Set;
	
	import flash.utils.describeType;
	import flash.utils.getDefinitionByName;
	
	import mesh.validations.Validator;
	
	import mx.utils.StringUtil;

	/**
	 * A class that describes the relationships for an entity and how it's persisted.
	 * 
	 * @author Dan Schultz
	 */
	public class EntityDescription
	{
		/**
		 * Generates an entity description from the given entity class.
		 * 
		 * @param entity The entity to generate the description from.
		 * @return A new entity description.
		 */
		public static function fromEntity(entity:Class):EntityDescription
		{
			var description:EntityDescription = new EntityDescription(entity);
			var classInfo:XML = describeType(entity);
			
			var relationsshipsXML:XMLList = classInfo..metadata.(@name == "Relationship");
			for each (var relationshipXML:XML in relationsshipsXML) {
				var to:XMLList = relationshipXML.arg.(@key == "to");
				
				description.hasRelationship(relationshipXML.parent().@name, getDefinitionByName(to.length() > 0 ? to.@value : relationshipXML.parent().@type) as Class);
			}
			
			var compositionsXML:XMLList = classInfo..metadata.(@name == "ComposedOf");
			for each (var composedOfXML:XML in compositionsXML) {
				var property:XMLList = composedOfXML.arg.(@key == "property");
				var type:XMLList = composedOfXML.arg.(@key == "type");
				var prefix:XMLList = composedOfXML.arg.(@key == "prefix");
				var mapping:XMLList = composedOfXML.arg.(@key == "mapping");
				
				var options:Object = {};
				options.prefix = prefix.@value.toString();
				options.mapping = StringUtil.trimArrayElements(mapping.@value.toString(), ",").split(",");
				
				description.composedOf(property.length() > 0 ? property.@value : composedOfXML.parent().@name, getDefinitionByName(type.length() > 0 ? type.@value : composedOfXML.parent().@type) as Class, options);
			}
			
			return description;
		}
		
		/**
		 * Constructor.
		 * 
		 * @param entity The entity being described.
		 */
		public function EntityDescription(entity:Class)
		{
			_entity = entity;
		}
		
		/**
		 * Adds an aggregate to the entity.
		 * 
		 * @param property The property on the entity that contains the aggregate.
		 * @param type The type of aggregate.
		 * @param options The options for the aggregate.
		 */
		public function composedOf(property:String, type:Class, options:Object = null):void
		{
			options = options == null ? {} : options;
			_aggregates.add( new Aggregate(entity, property, type, options) );
		}
		
		/**
		 * Adds a relationship to the entity.
		 * 
		 * @param property The property on the entity that defines the relationship.
		 * @param type The entity type to define for the relationship.
		 */
		public function hasRelationship(property:String, type:Class):void
		{
			_relationships.add( new Relationship(entity, property, type, Relationship.NOTHING) );
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
				   entity == description.entity;
		}
		
		/**
		 * Adds a validator 
		 * 
		 * @param validator
		 * 
		 */
		public function validate(validator:Validator):void
		{
			
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
		
		private var _aggregates:Set = new HashSet();
		/**
		 * The <code>Aggregates</code> for this entity.
		 */
		public function get aggregates():Set
		{
			return _aggregates;
		}
		
		private var _relationships:Set = new HashSet();
		/**
		 * The <code>Relationship</code>s for this entity.
		 */
		public function get relationships():Set
		{
			return _relationships;
		}
		
		private var _validators:Set = new HashSet();
		/**
		 * The <code>Validator</code>s for this entity.
		 */
		public function get validators():Set
		{
			return _validators;
		}
	}
}