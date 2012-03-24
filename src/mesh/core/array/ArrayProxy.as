package mesh.core.array
{
	import flash.utils.Proxy;
	import flash.utils.flash_proxy;

	/**
	 * The <code>ArrayProxy</code> is a class that allows an inheriting class to behave like 
	 * an array that supports <code>for each..in</code> loops.
	 * 
	 * @author Dan Schultz
	 */
	public class ArrayProxy extends Proxy
	{
		private var _copy:Function;
		
		/**
		 * Constructor.
		 * 
		 * @param copy A function that copies the elements of the array being proxied.
		 */
		public function ArrayProxy(copy:Function)
		{
			super();
			_copy = copy;
		}
		
		// Proxy methods to support for each..in loops.
		
		/**
		 * @private
		 */
		override flash_proxy function nextName(index:int):String
		{
			return (index-1).toString();
		}
		
		private var _iteratingItems:Array;
		private var _len:int;
		/**
		 * @private
		 */
		override flash_proxy function nextNameIndex(index:int):int
		{
			if (index == 0) {
				_iteratingItems = _copy();
				_len = _iteratingItems.length;
			}
			return index < _len ? index+1 : 0;
		}
		
		/**
		 * @private
		 */
		override flash_proxy function nextValue(index:int):*
		{
			return _iteratingItems[index-1];
		}
	}
}