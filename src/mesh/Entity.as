package mesh
{
	import collections.HashMap;
	import collections.HashSet;
	import collections.Set;
	
	import flash.utils.Proxy;
	import flash.utils.flash_proxy;
	import flash.utils.getDefinitionByName;
	import flash.utils.getQualifiedClassName;
	
	import reflection.clazz;

	/**
	 * An entity.
	 * 
	 * @author Dan Schultz
	 */
	public dynamic class Entity extends Proxy
	{
		private static const DESCRIPTIONS:HashMap = new HashMap();
		
		/**
		 * Constructor.
		 */
		public function Entity()
		{
			super();
			
			if (!DESCRIPTIONS.containsKey(clazz)) {
				DESCRIPTIONS.put(clazz, EntityDescription.fromEntity(clazz));
			}
		}
		
		/**
		 * Checks if two entities are equal.  By default, two entities are equal
		 * when they are of the same type, and their ID's are the same.
		 * 
		 * @param entity The entity to check.
		 * @return <code>true</code> if the entities are equal.
		 */
		public function equals(entity:Entity):Boolean
		{
			return entity != null && id.equals(entity.id);
		}
		
		/**
		 * Returns a generated hash value for this entity.  Two entities that represent
		 * the same data should return the same hash code.
		 * 
		 * @return A hash value.
		 */
		public function hashCode():Object
		{
			return id.guid;
		}
		
		/**
		 * Marks this entity as dirty.
		 */
		public function modified():void
		{
			_isDirty = true;
		}
		
		/**
		 * Marks this entity as being persisted.
		 */
		public function saved():void
		{
			_isDirty = false;
		}
		
		/**
		 * The class for this entity.
		 */
		public function get clazz():Class
		{
			return reflection.clazz(this);
		}
		
		private var _id:EntityID = new EntityID();
		/**
		 * An object that represents the ID for this entity.
		 */
		public function get id():EntityID
		{
			return _id;
		}
		
		private var _isDirty:Boolean;
		/**
		 * <code>true</code> if this entity is dirty and needs to be persisted.
		 */
		public function get isDirty():Boolean
		{
			return _isDirty;
		}
		
		/**
		 * Returns the set of <code>Aggregate</code>s for this entity.
		 */
		public function get aggregates():Set
		{
			return DESCRIPTIONS.grab(clazz).aggregates;
		}
		
		/**
		 * Returns the set of <code>Relationship</code>s for this entity.
		 */
		public function get relationships():Set
		{
			return DESCRIPTIONS.grab(clazz).relationships;
		}
		
		private var _valueObjects:Object = {};
		
		/**
		 * @private
		 */
		override flash_proxy function getProperty(name:*):*
		{
			name = getNameFromQName(name);
			
			if (_valueObjects.hasOwnProperty(name)) {
				return _valueObjects[name];
			}
			
			for each (var aggregate:Aggregate in aggregates) {
				if (aggregate.hasMappedProperty(name)) {
					return aggregate.getValue(this, name);
				}
			}
			
			return undefined;
		}
		
		/**
		 * @private
		 */
		override flash_proxy function hasProperty(name:*):Boolean
		{
			return flash_proxy::getProperty(name) !== undefined;
		}
		
		/**
		 * @private
		 */
		override flash_proxy function setProperty(name:*, value:*):void
		{
			name = getNameFromQName(name);
			for each (var aggregate:Aggregate in aggregates) {
				if (aggregate.property == name) {
					_valueObjects[name] = value;
					return;
				}
				
				if (aggregate.hasMappedProperty(name)) {
					aggregate.setValue(this, name, value);
				}
			}
		}
		
		private function getNameFromQName(name:*):String
		{
			if (name is QName) {
				name = name.localName;
			}
			return name;
		}
	}
}