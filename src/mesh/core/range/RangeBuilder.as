package mesh.core.range
{
	import mesh.core.reflection.newInstance;

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
			return newInstance(_clazz, _from, value, false);
		}
		
		public function toButNotIncluding(value:*):Range
		{
			return newInstance(_clazz, _from, value, true);
		}
	}
}