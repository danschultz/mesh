package mesh.services
{
	public class ParallelRequest extends CompoundRequest
	{
		private var _finishCount:int;
		
		public function ParallelRequest(requests:Array = null)
		{
			super(executeAll, requests);
		}
		
		override public function and(request:Request):Request
		{
			add(request);
			return this;
		}
		
		private function executeAll():void
		{
			for each (var request:Request in requests) {
				executeRequest(request);
			}
		}
		
		private function executeRequest(request:Request):void
		{
			request.execute({fault:fault, success:requestFinished});
		}
		
		private function requestFinished():void
		{
			if (++_finishCount == requests.length) {
				success();
			}
		}
	}
}