package mesh.services
{
	public class CompoundRequest extends Request
	{
		private var _requests:Array;
		private var _index:int;
		
		public function CompoundRequest(requests:Array)
		{
			super(executeNext);
			_requests = requests;
		}
		
		/**
		 * @inheritDoc
		 */
		override public function then(request:Request):Request
		{
			if (_requests.indexOf(request) == -1) {
				_requests.push(request);
			}
			return this;
		}
		
		private function executeRequest(request:Request):void
		{
			request.execute(
			{
				fault:function(f:Object):void
				{
					fault(f);
				},
				finish:function():void
				{
					executeNext();
				}
			});
		}
		
		private function executeNext():void
		{
			if (_index++ < _requests.length) {
				executeRequest(_requests[_index]);
			} else {
				finished();
			}
		}
	}
}