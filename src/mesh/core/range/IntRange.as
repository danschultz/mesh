package mesh.core.range
{
	public class IntRange extends Range
	{
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
			return max - min + 1;
		}
	}
}