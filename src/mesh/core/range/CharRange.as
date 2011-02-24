package mesh.core.range
{
	/**
	 * A range for single character strings.
	 * 
	 * @see Range#from()
	 * @author Dan Schultz
	 */
	public class CharRange extends Range
	{
		/**
		 * @copy Range#Range()
		 */
		public function CharRange(from:*, to:*, exclusive:Boolean=false)
		{
			super(from, to, exclusive);
		}
		
		/**
		 * @inheritDoc
		 */
		override protected function decrease(value:*, size:int):*
		{
			return String.fromCharCode(value.charCodeAt(0)-size);
		}
		
		/**
		 * @inheritDoc
		 */
		override protected function increase(value:*, size:int):*
		{
			return String.fromCharCode(value.charCodeAt(0)+size);
		}
		
		/**
		 * @inheritDoc
		 */
		override public function get length():int
		{
			return max.charCodeAt(0) - min.charCodeAt(0) + (!isExclusive ? 1 : 0);
		}
	}
}