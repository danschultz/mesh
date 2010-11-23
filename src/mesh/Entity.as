package mesh
{
	import collections.HashMap;
	import collections.Set;
	
	import flash.events.EventDispatcher;
	import flash.utils.getDefinitionByName;
	import flash.utils.getQualifiedClassName;

	/**
	 * An entity.
	 * 
	 * @author Dan Schultz
	 */
	public dynamic class Entity extends EventDispatcher
	{
		private static const DESCRIPTIONS:HashMap = new HashMap();
		
		/**
		 * Constructor.
		 */
		public function Entity()
		{
			super();
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
			return getDefinitionByName(getQualifiedClassName(this)) as Class;
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
		 * Returns the set of <code>Relationship</code>s for this entity.
		 */
		public function get relationships():Set
		{
			if (!DESCRIPTIONS.containsKey(clazz)) {
				DESCRIPTIONS.put(clazz, EntityDescription.fromEntity(clazz));
			}
			return DESCRIPTIONS.grab(clazz).relationships;
		}
	}
}