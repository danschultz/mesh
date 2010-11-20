package mesh
{
	import collections.HashMap;

	/**
	 * A class that describes the entities and how the entities are persisted in an 
	 * application.
	 * 
	 * @author Dan Schultz
	 */
	public class EntityModel
	{
		private var _descriptions:HashMap = new HashMap();
		private var _strategies:HashMap = new HashMap();
		
		/**
		 * Constructor.
		 */
		public function EntityModel()
		{
			
		}
		
		/**
		 * Adds the description of an entity and how the entity is persisted to this model.
		 * 
		 * @param description The description of the entity.
		 * @param strategy How the entity is persisted.
		 */
		public function addEntity(description:EntityDescription, strategy:PersistenceStrategy):void
		{
			_descriptions.put(description.entity, description);
			_strategies.put(description.entity, strategy);
		}
		
		/**
		 * Checks if the given entity belongs to this model.
		 * 
		 * @param entity The entity to check.
		 * @return <code>true</code> if the entity was found.
		 */
		public function containsEntity(entity:Class):Boolean
		{
			return _descriptions.containsKey(entity);
		}
		
		/**
		 * Removes the given entity from this model.
		 * 
		 * @param entity The entity to remove.
		 */
		public function removeEntity(entity:Class):void
		{
			_descriptions.remove(entity);
			_strategies.remove(entity);
		}
	}
}