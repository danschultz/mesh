package operations
{
	import mesh.operations.Operation;

	public class MockOperation extends Operation
	{
		public function MockOperation()
		{
			
		}
		
		public function mimicFault(summary:String, detail:String):void
		{
			fault(summary, detail);
		}
		
		private var _resultThrowsRTE:Boolean;
		public function mimicResult(data:Object, throwsRTE:Boolean):void
		{
			_resultThrowsRTE = throwsRTE;
			result(data);
		}
		
		override protected function parseResult(data:Object):Object
		{
			if (_resultThrowsRTE) {
				throw new Error();
			}
			return data;
		}
	}
}