package mesh.core.range
{
	public class RangeBuilder
	{
		private var _clazz:Class;
		private var _from:*;
		
		public function RangeBuilder(clazz:Class, from:*)
		{
			_clazz = clazz;
			_from = from;
		}
		
		public function to(value:*):Range
		{
			return new Range(_from, value, false);
		}
		
		public function toButExcluding(value:*):Range
		{
			return new Range(_from, value, true);
		}
	}
}