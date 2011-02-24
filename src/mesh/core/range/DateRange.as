package mesh.core.range
{
	public class DateRange extends Range
	{
		public function DateRange(from:*, to:*, exclusive:Boolean=false)
		{
			super(from, to, exclusive);
		}
		
		/**
		 * @inheritDoc
		 */
		override protected function decrease(value:*, size:int):*
		{
			var newValue:Date = new Date(value.getTime());
			newValue.setDate(newValue.date - size);
			return newValue;
		}
		
		/**
		 * @inheritDoc
		 */
		override protected function increase(value:*, size:int):*
		{
			var newValue:Date = new Date(value.getTime());
			newValue.setDate(newValue.date + size);
			return newValue;
		}
		
		/**
		 * @inheritDoc
		 */
		override public function get length():int
		{
			return (max.time - min.time) / 86400000;
		}
	}
}