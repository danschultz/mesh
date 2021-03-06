package mesh.model
{
	import flash.errors.IllegalOperationError;
	import flash.utils.Proxy;
	import flash.utils.flash_proxy;
	
	import mesh.core.reflection.Metadata;
	import mesh.core.reflection.Property;
	import mesh.mesh_internal;
	import mesh.model.associations.Association;
	import mesh.model.associations.HasManyAssociation;
	import mesh.model.associations.HasOneAssociation;
	
	use namespace mesh_internal;
	
	/**
	 * The <code>Associations</code> class is a hash of properties to their associations for an record.
	 * Each <code>Record</code> contains its own associations hash, and can be accessed through the
	 * <code>Record.associations</code> property.
	 * 
	 * <p>
	 * This class extends <code>Proxy</code> and provides looping over each association using the 
	 * <code>for each..in</code> keywords. In addition, you can retrieve and association using
	 * <code>.</code> (dot) syntax, where the keyword after the dot is the property defining the
	 * association.
	 * </p>
	 * 
	 * @author Dan Schultz
	 */
	public dynamic class Associations extends Proxy
	{
		private var _record:Record;
		private var _mappings:Object = {};
		private var _properties:Array = [];
		
		/**
		 * Constructor.
		 */
		public function Associations(record:Record)
		{
			super();
			_record = record;
			initialize();
		}
		
		/**
		 * @private
		 */
		mesh_internal function hasOne(property:String, options:Object = null):void
		{
			map(property, new HasOneAssociation(_record, property, options));
		}
		
		/**
		 * @private
		 */
		mesh_internal function hasMany(property:String, options:Object = null):void
		{
			var association:HasManyAssociation = new HasManyAssociation(_record, property, options);
			_record[property] = association;
			map(property, association);
		}
		
		private function initialize():void
		{
			for each (var property:Property in _record.reflect.properties) {
				for each (var metadata:Metadata in property.metadata) {
					if (metadata.name == "HasOne" || metadata.name == "HasMany") {
						this["h" + metadata.name.slice(1)](property.name, metadata.arguments)
					}
				}
			}
		}
		
		/**
		 * Checks if a property is mapped to an association.
		 * 
		 * @param property The property to check.
		 * @return <code>true</code> if the property is mapped.
		 */
		public function isAssociation(property:String):Boolean
		{
			return _mappings.hasOwnProperty(property);
		}
		
		/**
		 * Maps a property on an record to an association object.
		 * 
		 * @param property The property to map.
		 * @param association The association to map.
		 */
		public function map(property:String, association:Association):void
		{
			if (!isAssociation(property)) {
				_mappings[property] = association;
				_properties.push(property);
			}
		}
		
		/**
		 * Returns the association mapped to the given property.
		 * 
		 * @param property The association's property.
		 * @return An association, or <code>null</code> if one is not defined.
		 */
		public function mappedTo(property:String):Association
		{
			if (!isAssociation(property)) {
				throw new IllegalOperationError("Association undefined for " + _record.reflect.name + "." + property);
			}
			return _mappings[property];
		}
		
		/**
		 * Removes the association mapped to the given property.
		 * 
		 * @param property The property to remove the association on.
		 */
		public function unmap(property:String):void
		{
			if (isAssociation(property)) {
				delete _mappings[property];
				_properties.splice(_properties.indexOf(property), 1);
			}
		}
		
		/**
		 * @inheritDoc
		 */
		override flash_proxy function deleteProperty(name:*):Boolean
		{
			return name != null && isAssociation(name.toString()) ? unmap(name.toString()) : false;
		}
		
		/**
		 * @inheritDoc
		 */
		override flash_proxy function getProperty(name:*):*
		{
			return name != null && isAssociation(name.toString()) ? mappedTo(name.toString()) : undefined;
		}
		
		/**
		 * @inheritDoc
		 */
		override flash_proxy function hasProperty(name:*):Boolean
		{
			return name != null && isAssociation(name.toString());
		}
		
		/**
		 * @inheritDoc
		 */
		override flash_proxy function nextName(index:int):String
		{
			return _iteratingItems[index-1];
		}
		
		private var _iteratingItems:Array;
		private var _len:int;
		/**
		 * @inheritDoc
		 */
		override flash_proxy function nextNameIndex(index:int):int
		{
			if (index == 0) {
				_iteratingItems = _properties.concat();
				_len = _iteratingItems.length;
			}
			return index < _len ? index+1 : 0;
		}
		
		/**
		 * @inheritDoc
		 */
		override flash_proxy function nextValue(index:int):*
		{
			return _mappings[_iteratingItems[index-1]];
		}
	}
}