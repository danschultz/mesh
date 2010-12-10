package mesh
{
	import collections.HashMap;
	import collections.HashSet;
	
	import flash.utils.describeType;
	import flash.utils.getDefinitionByName;
	import flash.utils.getQualifiedSuperclassName;
	
	import inflections.pluralize;
	
	import mesh.adaptors.ServiceAdaptor;
	import mesh.associations.BelongsToRelationship;
	import mesh.associations.HasManyRelationship;
	import mesh.associations.HasOneRelationship;
	
	import mx.utils.StringUtil;
	
	import reflection.className;
	import reflection.clazz;
	import reflection.newInstance;

	public class EntityDescription
	{
		private static const RELATIONSHIPS:Object = {
			HasMany: HasManyRelationship,
			HasOne: HasOneRelationship,
			BelongsTo: BelongsToRelationship
		};
		
		private static const DESCRIPTIONS:HashMap = new HashMap();
		
		private var _description:XML;
		private var _metadata:XMLList;
		
		private var _relationships:HashSet = new HashSet();
		private var _aggregates:HashSet = new HashSet();
		private var _adaptor:ServiceAdaptor;
		
		public function EntityDescription(entityType:Class)
		{
			_entityType = entityType;
			_metadata = describeType(entityType)..metadata;
			
			parseAdaptor();
			parseAggregates();
			parseRelationships();
		}
		
		public static function describe(entity:Object):EntityDescription
		{
			if (!(entity is Class)) {
				entity = clazz(entity);
			}
			
			if (!DESCRIPTIONS.containsKey(entity)) {
				
			}
			
			return DESCRIPTIONS.grab(entity);
		}
		
		public function equals(description:EntityDescription):Boolean
		{
			return description != null && entityType == description.entityType;
		}
		
		public function hashCode():Object
		{
			return _entityType;
		}
		
		private function parseAggregates():void
		{
			for each (var composedOfXML:XML in _metadata.(@name == "ComposedOf")) {
				var property:XMLList = composedOfXML.arg.(@key == "property");
				var type:XMLList = composedOfXML.arg.(@key == "type");
				var prefix:XMLList = composedOfXML.arg.(@key == "prefix");
				var mapping:XMLList = composedOfXML.arg.(@key == "mapping");
				
				var options:Object = {};
				options.prefix = prefix.@value.toString();
				options.mapping = StringUtil.trimArrayElements(mapping.@value.toString(), ",").split(",");
				
				_aggregates.add( new Aggregate(entityType, property.length() > 0 ? property.@value : composedOfXML.parent().@name, getDefinitionByName(type.length() > 0 ? type.@value : composedOfXML.parent().@type) as Class, options) );
			}
		}
		
		private function parseAdaptor():void
		{
			for each (var adaptorXML:XML in describeType(this)..metadata.(@name == "ServiceAdaptor")) {
				var options:Object = {};
				
				for each (var argXML:XML in adaptorXML..arg) {
					options[argXML.@key] = argXML.@value.toString();
				}
				
				_adaptor = ServiceAdaptor( newInstance(getDefinitionByName(adaptorXML.arg.(@key == "type").@value) as Class, entityType, options) );
				break;
			}
		}
		
		private function parseRelationships():void
		{
			for each (var relationshipXML:XML in _metadata.(@name == "HasOne" || @name == "HasMany" || @name == "BelongsTo")) {
				var kind:String = relationshipXML.@name;
				var options:Object = {};
				
				for each (var argXML:XML in relationshipXML..arg) {
					options[argXML.@key] = argXML.@value.toString();
				}
				
				if (!options.hasOwnProperty("type")) {
					options.type = relationshipXML.parent().@type;
				}
				options.type = getDefinitionByName(options.type) as Class;
				
				// try to grab the property auto-magically.
				if (!options.hasOwnProperty("property")) {
					// first try to see if there's an accessor we can use.
					if (relationshipXML.parent().name() == "accessor") {
						options.property = relationshipXML.parent().@name;
					}
						// pluralize the entity type if we're a has many.
					else if (kind == "HasMany") {
						var pluralizedClassName:String = pluralize(className(options.type));
						options.property = pluralizedClassName.substr(0, 1).toLowerCase() + pluralizedClassName.substr(1);
					}
				}
				
				_relationships.add( newInstance(RELATIONSHIPS[kind], options.type, options.property, options) );
			}
		}
		
		private var _entityType:Class;
		public function get entityType():Class
		{
			return _entityType;
		}
		
		private var _parentEntityType:*;
		public function get parentEntityType():Class
		{
			if (_parentEntityType === undefined) {
				_parentEntityType = getDefinitionByName(getQualifiedSuperclassName(entityType)) as Class;
			}
			return _parentEntityType;
		}
	}
}