package mesh.core
{
	import flash.utils.Dictionary;

	/**
	 * The <code>Set</code> class is a list collection that ensures that only one copy of an element
	 * belongs to the list. This set is implemented as an <code>IList</code> and dispatches collection
	 * change events when elements are added and removed. The set can also be assigned to data providers
	 * of list and tree controls in Flex.
	 * 
	 * <p>
	 * This set supports ordered iteration.
	 * </p>
	 * 
	 * @author Dan Schultz
	 */
	public class Set extends List
	{
		private var _elements:Dictionary = new Dictionary();
		
		/**
		 * @copy List#List()
		 */
		public function Set(source:Array = null)
		{
			super(source);
		}
		
		/**
		 * @inheritDoc
		 */
		override public function addItemAt(item:Object, index:int):void
		{
			if (!contains(item)) {
				_elements[item] = true;
				super.addItemAt(item, length);
			}
		}
		
		/**
		 * @inheritDoc
		 */
		override public function contains(item:Object):Boolean
		{
			return _elements[item] != null;
		}
		
		/**
		 * @private
		 */
		override public function setItemAt(item:Object, index:int):Object
		{
			// Disabled
			return null;
		}
		
		/**
		 * @inheritDoc
		 */
		override public function removeItemAt(index:int):Object
		{
			var item:Object = getItemAt(index);
			if (item != null) {
				delete _elements[item];
			}
			super.removeItemAt(index);
			return item;
		}
	}
}