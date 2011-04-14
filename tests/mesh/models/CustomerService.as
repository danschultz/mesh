package mesh.models
{
	import mesh.operations.Operation;
	import mesh.services.QueryRequest;
	import mesh.services.Service;
	
	public class CustomerService extends Service
	{
		public function CustomerService()
		{
			super();
		}
		
		override public function findOne(id:*):QueryRequest
		{
			return new QueryRequest(this, function():Operation
			{
				return adaptor.createOperation("find", [id]);
			});
		}
	}
}