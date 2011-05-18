package mesh.services
{
	import flash.utils.flash_proxy;
	
	use namespace flash_proxy;

	public class WrappedRequest extends Request
	{
		private var _request:Request;
		
		public function WrappedRequest(block:Function)
		{
			super(block);
		}
		
		override protected function executeBlock(block:Function):void
		{
			if (_request == null) {
				_request = block.apply(null, blockArgs());
				_request.addHandler({
					fault:fault, 
					success:function():void {
						result(_request.object);
						success();
					}
				});
			}
			_request.execute();
		}
	}
}