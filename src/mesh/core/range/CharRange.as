package mesh.core.range
{
	public class CharRange extends Range
	{
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
			return max.charCodeAt(0) - min.charCodeAt(0) + 1;
		}
	}
}