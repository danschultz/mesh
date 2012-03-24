package mesh.model
{
	import flash.errors.IllegalOperationError;
	import flash.utils.Dictionary;

	public class RecordState
	{
		public static const SYNCED:int = 0x1;
		public static const DIRTY:int = 0x2;
		public static const BUSY:int = 0x4;
		
		public static const ERRORED:int = 0x1000;
		
		public static const INIT:int = 0x100;
		public static const LOADED:int = 0x200;
		public static const DESTROYED:int = 0x400;
		
		public function RecordState(value:int)
		{
			_value = value;
		}
		
		private static const CACHE:Dictionary = new Dictionary();
		private static function cache(value:int):RecordState
		{
			var result:RecordState = CACHE[value];
			if (result == null) {
				result = CACHE[value] = new RecordState(value);
			}
			return result;
		}
		
		public static function init():RecordState
		{
			return cache(INIT | DIRTY);
		}
		
		public static function loaded():RecordState
		{
			return cache(LOADED | SYNCED);
		}
		
		public static function destroy():RecordState
		{
			return cache(DESTROYED | DIRTY);
		}
		
		public function dirty():RecordState
		{
			return cache(value | DIRTY);
		}
		
		public function equals(obj:Object):Boolean
		{
			return obj == this || (obj is RecordState && value == obj.value);
		}
		
		public function busy():RecordState
		{
			return cache(value | BUSY);
		}
		
		public function synced():RecordState
		{
			if (isBusy) {
				if ((value & INIT || value & LOADED) && value & BUSY) {
					return loaded();
				} else if (value & DESTROYED && value & BUSY) {
					return cache(DESTROYED | SYNCED);
				}
			}
			
			throw new IllegalOperationError("Record state change not defined.");
		}
		
		public function get isBusy():Boolean
		{
			return (value & BUSY) != 0;
		}
		
		public function get isDestroyed():Boolean
		{
			return (value & DESTROYED) != 0;
		}
		
		public function get isRemote():Boolean
		{
			return (value & LOADED) != 0 || willBeDestroyed;
		}
		
		public function get isSynced():Boolean
		{
			return (value & DIRTY) == 0;
		}
		
		public function get willBeCreated():Boolean
		{
			return (value & INIT) != 0 && !isSynced && !isBusy;
		}
		
		public function get willBeUpdated():Boolean
		{
			return (value & LOADED) != 0 && !isSynced && !isBusy;
		}
		
		public function get willBeDestroyed():Boolean
		{
			return (value & DESTROYED) != 0 && !isSynced && !isBusy;
		}
		
		private var _value:int;
		public function get value():int
		{
			return _value;
		}
	}
}