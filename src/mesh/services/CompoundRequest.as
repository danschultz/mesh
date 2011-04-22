package mesh.services
{
	public class CompoundRequest extends Request
	{
		public function CompoundRequest(block:Function, requests:Array = null)
		{
			super(block);
			
			for each (var request:Request in requests) {
				add(request);
			}
		}
		
		public function add(request:Request):void
		{
			if (requests.indexOf(request) == -1) {
				requests.push(request);
			}
		}
		
		private var _requests:Array = [];
		protected function get requests():Array
		{
			return _requests;
		}
	}
}