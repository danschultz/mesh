package mesh.services
{
	public dynamic class WhereQueryRequest extends ListQueryRequest
	{
		public function WhereQueryRequest(service:Service, deserializer:Function, block:Function)
		{
			super(service, deserializer, block);
		}
	}
}