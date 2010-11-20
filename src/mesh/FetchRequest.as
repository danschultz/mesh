package mesh
{
	import operations.Operation;

	public class FetchRequest
	{
		private var _operation:Operation;
		private var _repository:Repository;
		
		public function FetchRequest(operation:Operation, repository:Repository)
		{
			_operation = operation;
			_repository = repository;
		}
	}
}