package mesh
{
	import collections.HashMap;
	import collections.HashSet;
	import collections.ISet;
	import collections.ImmutableSet;
	
	import flash.utils.Proxy;
	import flash.utils.describeType;
	import flash.utils.getDefinitionByName;
	import flash.utils.getQualifiedSuperclassName;
	
	import inflections.pluralize;
	
	import mesh.adaptors.ServiceAdaptor;
	import mesh.associations.BelongsToRelationship;
	import mesh.associations.HasManyRelationship;
	import mesh.associations.HasOneRelationship;
	import mesh.associations.Relationship;
	
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
		private var _propertyToRelationship:HashMap = new HashMap();
		
		private var _aggregates:HashSet = new HashSet();
		private var _propertyToAggregate:HashMap = new HashMap();
		
		private var _adaptor:ServiceAdaptor;
		private var _validators:HashSet = new HashSet();
		
		public function EntityDescription(entityType:Class)
		{
			_entityType = entityType;
			_description = describeType(entityType);
			_metadata = _description..metadata;
			
			parseAdaptor();
			parseAggregates();
			parseRelationships();
			parseValidators();
		}
		
		public static function describe(entity:Object):EntityDescription
		{
			if (!(entity is Class)) {
				entity = clazz(entity);
			}
			
			if (!DESCRIPTIONS.containsKey(entity)) {
				DESCRIPTIONS.put(entity, new EntityDescription(entity as Class));
			}
			
			return DESCRIPTIONS.grab(entity);
		}
		
		public function addAggregates(...aggregates):void
		{
			for each (var aggregate:Aggregate in aggregates) {
				_aggregates.add(aggregate);
				_propertyToAggregate.put(aggregate.property, aggregate);
				
				for each (var mapping:String in aggregate.mappings) {
					_propertyToAggregate.put(mapping, aggregate);
				}
			}
		}
		
		public function addRelationships(...relationships):void
		{
			for each (var relationship:Relationship in relationships) {
				_relationships.add(relationship);
				_propertyToRelationship.put(relationship.property, relationship);
			}
		}
		
		public function addValidators(...validators):void
		{
			_validators.addAll(validators);
		}
		
		public function equals(description:EntityDescription):Boolean
		{
			return description != null && entityType == description.entityType;
		}
		
		public function getAggregateForProperty(property:String):Aggregate
		{
			return _propertyToAggregate.grab(property);
		}
		
		public function getRelationshipForProperty(property:String):Relationship
		{
			return _propertyToRelationship.grab(property);
		}
		
		public function hashCode():Object
		{
			return _entityType;
		}
		
		private function parseAggregates():void
		{
			var aggregates:Array = [];
			for each (var composedOfXML:XML in _metadata.(@name == "ComposedOf")) {
				var property:XMLList = composedOfXML.arg.(@key == "property");
				var type:XMLList = composedOfXML.arg.(@key == "type");
				var prefix:XMLList = composedOfXML.arg.(@key == "prefix");
				var mapping:XMLList = composedOfXML.arg.(@key == "mapping");
				
				var options:Object = {};
				options.prefix = prefix.@value.toString();
				options.mapping = StringUtil.trimArrayElements(mapping.@value.toString(), ",").split(",");
				
				addAggregates(new Aggregate(entityType, property.length() > 0 ? property.@value : composedOfXML.parent().@name, getDefinitionByName(type.length() > 0 ? type.@value : composedOfXML.parent().@type) as Class, options));
			}
			
			var parent:Class = parentEntityType;
			while (parent != null) {
				var description:EntityDescription = describe(parent);
				addAggregates.apply(null, description.aggregates.toArray());
				parent = description.parentEntityType;
			}
		}
		
		private function parseAdaptor():void
		{
			for each (var adaptorXML:XML in _metadata.(@name == "ServiceAdaptor")) {
				var options:Object = {};
				
				for each (var argXML:XML in adaptorXML..arg) {
					options[argXML.@key] = argXML.@value.toString();
				}
				
				_adaptor = ServiceAdaptor( newInstance(getDefinitionByName(adaptorXML.arg.(@key == "type").@value) as Class, entityType, options) );
				break;
			}
			
			var parent:Class = parentEntityType;
			while (_adaptor == null && parent != null) {
				var description:EntityDescription = describe(parent);
				_adaptor = description.adaptor;
				parent = description.parentEntityType;
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
				
				addRelationships( newInstance(RELATIONSHIPS[kind], entityType, options.property, options.type, options) );
			}
			
			var parent:Class = parentEntityType;
			while (parent != null) {
				var description:EntityDescription = describe(parent);
				addRelationships.apply(null, description.relationships.toArray());
				parent = description.parentEntityType;
			}
		}
		
		private function parseValidators():void
		{
			for each (var validateXML:XML in _metadata.(@name == "Validate")) {
				var options:Object = {};
				
				for each (var argXML:XML in validateXML..arg) {
					if (argXML.@key != "validator") {
						options[argXML.@key] = argXML.@value.toString();
					}
				}
				
				if (validateXML.parent().name() == "accessor") {
					options["property"] = validateXML.parent().@name.toString();
				}
				
				if (options.hasOwnProperty("properties")) {
					options.properties = StringUtil.trimArrayElements(options.properties, ",").split(",");
				}
				
				addValidators(newInstance(getDefinitionByName(validateXML.arg.(@key == "validator").@value) as Class, options));
			}
		}
		
		public function get aggregates():ISet
		{
			return new ImmutableSet(_aggregates);
		}
		
		public function get relationships():ISet
		{
			return new ImmutableSet(_relationships);
		}
		
		public function get adaptor():ServiceAdaptor
		{
			return _adaptor;
		}
		
		public function get validators():ISet
		{
			return new ImmutableSet(_validators);
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
				
				if (_parentEntityType == Proxy) {
					_parentEntityType = null;
				}
			}
			return _parentEntityType;
		}
		
		private var _properties:HashSet;
		public function get properties():ISet
		{
			if (_properties == null) {
				_properties = new HashSet();
				_properties.addAll(_propertyToAggregate.keys());
				_properties.addAll(_propertyToRelationship.keys());
				
				for each (var accessorXML:XML in _description..accessor) {
					_properties.add(accessorXML.@name);
				}
			}
			return _properties;
		}
	}
}