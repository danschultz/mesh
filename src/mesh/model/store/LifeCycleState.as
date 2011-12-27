package mesh.model.store
{
	public class LifeCycleState
	{
		public static const CREATED:LifeCycleState = new LifeCycleState(0);
		public static const PERSISTED:LifeCycleState = new LifeCycleState(1);
		public static const DESTROYED:LifeCycleState = new LifeCycleState(2);
		
		public function LifeCycleState(value:int)
		{
			_value = value;
		}
		
		private var _value:int;
		internal function get value():int
		{
			return _value;
		}
	}
}