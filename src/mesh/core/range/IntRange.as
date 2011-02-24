package mesh.core.range
{
	/**
	 * A range for integers.
	 * 
	 * @see Range#from()
	 * @author Dan Schultz
	 */
	public class IntRange extends Range
	{
		/**
		 * @copy Range#Range()
		 */
		public function IntRange(from:*, to:*, exclusive:Boolean = false)
		{
			super(from, to, exclusive);
		}
		
		/**
		 * @inheritDoc
		 */
		override protected function decrease(value:*, size:int):*
		{
			return value - size;
		}
		
		/**
		 * @inheritDoc
		 */
		override protected function increase(value:*, size:int):*
		{
			return value + size;
		}
		
		/**
		 * @inheritDoc
		 */
		override public function get length():int
		{
			return max - min + (!isExclusive ? 1 : 0);
		}
	}
}