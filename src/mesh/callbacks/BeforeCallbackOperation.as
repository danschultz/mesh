package mesh.callbacks
{
	import operations.MethodOperation;
	
	public class BeforeCallbackOperation extends CallbackOperation
	{
		public function BeforeCallbackOperation(func:Function)
		{
			super(func);
		}
		
		override protected function parseResult(data:Object):Object
		{
			if (data != null && data == false) {
				fault("Callback halted operation");
			}
			return data;
		}
	}
}