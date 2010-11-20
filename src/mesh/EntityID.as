package mesh
{
	import mx.utils.UIDUtil;

	public class EntityID
	{
		public function EntityID()
		{
			_guid = UIDUtil.createUID();
		}
		
		public function equals(obj:EntityID):Boolean
		{
			return obj != null && guid == obj.guid;
		}
		
		private var _externalID:Object;
		public function get externalID():Object
		{
			return _externalID;
		}
		public function set externalID(value:Object):void
		{
			_externalID = value;
		}
		
		private var _guid:String;
		public function get guid():String
		{
			return _guid;
		}
	}
}