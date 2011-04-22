package mesh.services
{
	public class SequentialRequest extends CompoundRequest
	{
		private var _index:int;
		
		public function SequentialRequest(requests:Array = null)
		{
			super(executeNext, requests);
		}
		
		/**
		 * @inheritDoc
		 */
		override public function then(request:Request):Request
		{
			add(request);
			return this;
		}
		
		private function executeRequest(request:Request):void
		{
			request.execute({fault:fault, success:executeNext});
		}
		
		private function executeNext():void
		{
			if (_index < requests.length) {
				executeRequest(requests[_index++]);
			} else {
				success();
			}
		}
	}
}