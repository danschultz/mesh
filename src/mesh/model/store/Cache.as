package mesh.model.store
{
	import flash.utils.Dictionary;
	
	import mesh.core.reflection.reflect;
	
	/**
	 * The <code>Cache</code> is an internal structure used by the <code>Store</code> to store
	 * its elements.
	 * 
	 * @author Dan Schultz
	 */
	public class Cache
	{
		private var _indexes:Dictionary = new Dictionary();
		
		public function Cache()
		{
			
		}
		
		/**
		 * Determines the class type of an object. This method can be overridden by sub-classes.
		 * By default, this method returns the class type of the object.
		 * 
		 * @param data The object to determine the type for.
		 * @return A class type.
		 */
		protected function determineType(data:Object):Class
		{
			return reflect(data).clazz;
		}
		
		/**
		 * Returns a list of all the data with the given type.
		 * 
		 * @param type The types to retrieve.
		 * @return An indexed list.
		 */
		public function findIndex(type:Class):Index
		{
			return index(type);
		}
		
		/**
		 * Inserts an item into the cache.
		 * 
		 * @param item The item to insert.
		 */
		public function insert(item:Object):void
		{
			findIndex(determineType(item)).add(item);
		}
		
		/**
		 * Removes an item from the cache.
		 * 
		 * @param item The item to remove.
		 */
		public function remove(item:Object):void
		{
			findIndex(determineType(item)).remove(item);
		}
		
		private function index(type:Class):Index
		{
			if (_indexes[type] == null) {
				_indexes[type] = new Index();
			}
			return _indexes[type];
		}
	}
}