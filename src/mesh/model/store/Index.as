package mesh.model.store
{
	import collections.HashMap;
	
	import mesh.core.List;
	
	import mx.collections.IList;

	/**
	 * A index of arbitrary store data.
	 * 
	 * @author Dan Schultz
	 */
	public class Index
	{
		private var _index:HashMap = new HashMap();
		private var _items:List = new List();
		
		/**
		 * Constructor.
		 */
		public function Index()
		{
			
		}
		
		/**
		 * Returns all elements in the index.
		 * 
		 * @return The index's elements.
		 */
		public function all():IList
		{
			return _items;
		}
		
		/**
		 * Returns data that mapped to the given index.
		 * 
		 * @param id The index to grab.
		 * @return The mapped data.
		 */
		public function byId(id:Object):*
		{
			var element:Element = _index.grab(id);
			return element != null ? element.object : null;
		}
		
		/**
		 * Checks if the index contains an object with the given ID.
		 * 
		 * @param id The ID to check.
		 * @return <code>true</code> if the object was found.
		 */
		public function contains(id:Object):Boolean
		{
			return _index.containsKey(id);
		}
		
		internal function insert(id:Object, data:Object):void
		{
			remove(id);
			
			var element:Element = new Element(data, _items.length);
			_index.put(id, element);
			_items.add(data);
		}
		
		internal function remove(id:Object):void
		{
			var element:Element = _index.remove(id);
			if (element != null) {
				_items.removeItemAt(element.index);
			}
		}
	}
}

class Element
{
	public var object:Object;
	public var index:int;
	
	public function Element(object:Object, index:int)
	{
		this.object = object;
		this.index = index;
	}
}